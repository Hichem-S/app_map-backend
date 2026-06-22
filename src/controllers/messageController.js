const { query }  = require("../config/database");
const wsService  = require("../services/wsService");

// GET /api/messages/users
const getUsers = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT id, name, email, avatar, role, last_seen
       FROM users WHERE is_active = true AND id != $1 ORDER BY name`,
      [req.user.id]
    );
    const users = result.rows.map((u) => ({
      ...u,
      is_online: wsService.isOnline(u.id),
    }));
    res.json({ success: true, data: users });
  } catch (err) {
    next(err);
  }
};

// GET /api/messages/conversations
const getConversations = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const result = await query(
      `SELECT
         c.id, c.type, c.name, c.created_at,
         (SELECT row_to_json(m)
          FROM (SELECT cm2.content, cm2.sender_id, cm2.created_at
                FROM chat_messages cm2
                WHERE cm2.conversation_id = c.id
                ORDER BY cm2.created_at DESC LIMIT 1) m
         ) AS last_message,
         (SELECT COUNT(*)::int FROM chat_messages m
          WHERE m.conversation_id = c.id
          AND m.created_at > COALESCE(mb.last_read_at, '1970-01-01'::timestamp)
          AND m.sender_id != $1
         ) AS unread_count,
         (SELECT json_agg(json_build_object(
             'id', cm3.user_id,
             'name', COALESCE(u.name, 'Deleted User'),
             'avatar', u.avatar,
             'role', COALESCE(u.role, 'user')
           ))
          FROM chat_members cm3
          LEFT JOIN users u ON u.id = cm3.user_id
          WHERE cm3.conversation_id = c.id AND cm3.user_id != $1
         ) AS other_members
       FROM chat_conversations c
       JOIN chat_members mb ON mb.conversation_id = c.id AND mb.user_id = $1
       ORDER BY
         (SELECT MAX(created_at) FROM chat_messages WHERE conversation_id = c.id) DESC NULLS LAST,
         c.created_at DESC`,
      [userId]
    );

    const rows = result.rows;

    // Auto-repair: if a direct conversation has no other_members but has messages
    // from another user, restore that user into chat_members and return their info.
    for (const row of rows) {
      if (row.other_members || row.type !== 'direct') continue;
      const senderId = row.last_message?.sender_id;
      if (!senderId || senderId === userId) continue;

      const userRes = await query(
        `SELECT id, name, avatar, role FROM users WHERE id = $1`,
        [senderId]
      );
      if (!userRes.rows.length) continue;

      // Restore the missing chat_members row so future queries work natively
      await query(
        `INSERT INTO chat_members (conversation_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
        [row.id, senderId]
      );
      row.other_members = [userRes.rows[0]];
    }

    res.json({ success: true, data: rows });
  } catch (err) {
    next(err);
  }
};

// Helper – fetch a single conversation with full details (same shape as getConversations)
const _fetchConv = (convId, userId) =>
  query(
    `SELECT
       c.id, c.type, c.name, c.created_at,
       (SELECT row_to_json(m)
        FROM (SELECT cm2.content, cm2.sender_id, cm2.created_at
              FROM chat_messages cm2
              WHERE cm2.conversation_id = c.id
              ORDER BY cm2.created_at DESC LIMIT 1) m
       ) AS last_message,
       (SELECT COUNT(*)::int FROM chat_messages m
        WHERE m.conversation_id = c.id
          AND m.created_at > COALESCE(mb.last_read_at, '1970-01-01'::timestamp)
          AND m.sender_id != $2
       ) AS unread_count,
       (SELECT json_agg(json_build_object(
           'id', cm3.user_id,
           'name', COALESCE(u.name, 'Deleted User'),
           'avatar', u.avatar,
           'role', COALESCE(u.role, 'user')
         ))
        FROM chat_members cm3
        LEFT JOIN users u ON u.id = cm3.user_id
        WHERE cm3.conversation_id = c.id AND cm3.user_id != $2
       ) AS other_members
     FROM chat_conversations c
     JOIN chat_members mb ON mb.conversation_id = c.id AND mb.user_id = $2
     WHERE c.id = $1`,
    [convId, userId]
  );

// POST /api/messages/conversations
const createConversation = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { type = "direct", name, member_ids } = req.body;

    if (!Array.isArray(member_ids) || member_ids.length === 0) {
      return res.status(400).json({ success: false, message: "member_ids required" });
    }

    const allMembers = [...new Set([userId, ...member_ids])];

    // Dedup direct conversations
    if (type === "direct" && allMembers.length === 2) {
      const other = member_ids[0];
      const existing = await query(
        `SELECT c.id FROM chat_conversations c
         JOIN chat_members a ON a.conversation_id = c.id AND a.user_id = $1
         JOIN chat_members b ON b.conversation_id = c.id AND b.user_id = $2
         WHERE c.type = 'direct' LIMIT 1`,
        [userId, other]
      );
      if (existing.rows.length) {
        const full = await _fetchConv(existing.rows[0].id, userId);
        return res.json({ success: true, data: full.rows[0] });
      }
    }

    const convRes = await query(
      `INSERT INTO chat_conversations (type, name, created_by) VALUES ($1, $2, $3) RETURNING id`,
      [type, name || null, userId]
    );
    const convId = convRes.rows[0].id;

    for (const mid of allMembers) {
      await query(
        `INSERT INTO chat_members (conversation_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
        [convId, mid]
      );
    }

    const full = await _fetchConv(convId, userId);
    res.status(201).json({ success: true, data: full.rows[0] });
  } catch (err) {
    next(err);
  }
};

// GET /api/messages/conversations/:id
const getMessages = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { id }  = req.params;
    const limit   = Math.min(parseInt(req.query.limit) || 50, 100);
    const before  = req.query.before;

    const member = await query(
      "SELECT 1 FROM chat_members WHERE conversation_id = $1 AND user_id = $2",
      [id, userId]
    );
    if (!member.rows.length) {
      return res.status(403).json({ success: false, message: "Not a member" });
    }

    const params = before ? [id, limit, before] : [id, limit];
    const result = await query(
      `SELECT m.id, m.content, m.created_at,
              json_build_object('id', u.id, 'name', u.name, 'avatar', u.avatar) AS sender
       FROM chat_messages m
       JOIN users u ON u.id = m.sender_id
       WHERE m.conversation_id = $1
       ${before ? "AND m.created_at < $3" : ""}
       ORDER BY m.created_at DESC
       LIMIT $2`,
      params
    );

    // Mark as read
    await query(
      "UPDATE chat_members SET last_read_at = NOW() WHERE conversation_id = $1 AND user_id = $2",
      [id, userId]
    );

    res.json({ success: true, data: result.rows.reverse() });
  } catch (err) {
    next(err);
  }
};

// POST /api/messages/conversations/:id
const sendMessage = async (req, res, next) => {
  try {
    const userId  = req.user.id;
    const { id }  = req.params;
    const content = req.body.content?.trim();

    if (!content) {
      return res.status(400).json({ success: false, message: "content required" });
    }

    const member = await query(
      "SELECT 1 FROM chat_members WHERE conversation_id = $1 AND user_id = $2",
      [id, userId]
    );
    if (!member.rows.length) {
      return res.status(403).json({ success: false, message: "Not a member" });
    }

    const msgRes = await query(
      `INSERT INTO chat_messages (conversation_id, sender_id, content)
       VALUES ($1, $2, $3) RETURNING *`,
      [id, userId, content]
    );
    const message = msgRes.rows[0];

    const senderRes = await query("SELECT id, name, avatar FROM users WHERE id = $1", [userId]);
    const sender = senderRes.rows[0];

    // Mark sender as read
    await query(
      "UPDATE chat_members SET last_read_at = NOW() WHERE conversation_id = $1 AND user_id = $2",
      [id, userId]
    );

    // Notify other members via WS
    const membersRes = await query(
      "SELECT user_id FROM chat_members WHERE conversation_id = $1 AND user_id != $2",
      [id, userId]
    );

    const wsPayload = {
      type: "new_message",
      message: {
        id:              message.id,
        conversation_id: id,
        content:         message.content,
        created_at:      message.created_at,
        sender:          { id: sender.id, name: sender.name, avatar: sender.avatar },
      },
    };

    membersRes.rows.forEach(({ user_id }) => wsService.sendToUser(user_id, wsPayload));

    res.status(201).json({
      success: true,
      data: { ...message, sender: { id: sender.id, name: sender.name, avatar: sender.avatar } },
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/messages/conversations/:id/read
const markAsRead = async (req, res, next) => {
  try {
    await query(
      "UPDATE chat_members SET last_read_at = NOW() WHERE conversation_id = $1 AND user_id = $2",
      [req.params.id, req.user.id]
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/messages/conversations/:id
const deleteConversation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Only members can delete
    const member = await query(
      "SELECT 1 FROM chat_members WHERE conversation_id = $1 AND user_id = $2",
      [id, userId]
    );
    if (!member.rows.length) {
      return res.status(403).json({ success: false, message: "Not a member" });
    }

    // Cascades delete messages and members automatically
    await query("DELETE FROM chat_conversations WHERE id = $1", [id]);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

module.exports = { getUsers, getConversations, createConversation, getMessages, sendMessage, markAsRead, deleteConversation };
