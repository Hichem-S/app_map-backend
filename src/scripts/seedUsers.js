const bcrypt = require("bcryptjs");
const { query } = require("../config/database");
require("dotenv").config({ path: require("path").join(__dirname, "../../.env") });

const users = [
  { name: "Admin ISET",      email: "admin@iset.tn",      password: "admin123",      role: "admin"      },
  { name: "Magazinier ISET", email: "magazinier@iset.tn", password: "magazinier123", role: "magazinier" },
  { name: "Technicien ISET", email: "technicien@iset.tn", password: "technicien123", role: "technicien" },
];

const seed = async () => {
  const keepEmails = users.map(u => u.email);

  // Delete all users not in the seed list
  const deleted = await query(
    `DELETE FROM users WHERE email != ALL($1) RETURNING email`,
    [keepEmails]
  );
  if (deleted.rows.length) {
    console.log(`Deleted ${deleted.rows.length} other user(s):`);
    deleted.rows.forEach(r => console.log(`  - ${r.email}`));
    console.log();
  }

  // Upsert the three seed users
  console.log("Seeding users...\n");
  for (const u of users) {
    const hashed = await bcrypt.hash(u.password, 12);
    const res = await query(
      `INSERT INTO users (name, email, password, role, email_verified, is_active)
       VALUES ($1, $2, $3, $4, true, true)
       ON CONFLICT (email) DO UPDATE
         SET role = EXCLUDED.role,
             password = EXCLUDED.password,
             email_verified = true,
             is_active = true,
             updated_at = NOW()
       RETURNING name, email, role`,
      [u.name, u.email, hashed, u.role]
    );
    const row = res.rows[0];
    console.log(`✓  ${row.role.padEnd(12)} ${row.email}  /  password: ${u.password}`);
  }
  console.log("\nDone. Only these 3 accounts exist now.");
  process.exit(0);
};

seed().catch((err) => { console.error(err); process.exit(1); });
