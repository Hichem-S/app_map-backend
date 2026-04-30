# Flutter Backend — Express + PostgreSQL + MQTT + WebSocket

## Stack
- **Runtime**: Node.js + Express
- **Database**: PostgreSQL (via `pg`)
- **Auth**: JWT (access + refresh tokens)
- **Real-time**: WebSocket (`ws`)
- **IoT**: MQTT (`mqtt`)
- **File Uploads**: Multer
- **Security**: Helmet, CORS, Rate Limiting

---

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js       # PostgreSQL pool
│   │   └── migrate.js        # DB migration (creates tables)
│   ├── controllers/
│   │   ├── authController.js
│   │   └── deviceController.js
│   ├── middleware/
│   │   ├── auth.js           # JWT authentication
│   │   ├── errorHandler.js
│   │   ├── upload.js         # Multer file upload
│   │   └── validate.js
│   ├── routes/
│   │   ├── auth.js
│   │   └── devices.js
│   ├── services/
│   │   ├── mqttService.js    # MQTT broker connection
│   │   └── wsService.js      # WebSocket server
│   ├── app.js                # Express app
│   └── server.js             # Entry point
├── uploads/                  # Uploaded files
├── .env.example
└── package.json
```

---

## Setup

### 1. Install dependencies
```bash
npm install
```

### 2. Configure environment
```bash
cp .env.example .env
# Edit .env with your DB credentials and secrets
```

### 3. Create database
```sql
CREATE DATABASE flutter_app;
```

### 4. Run migrations
```bash
npm run db:migrate
```

### 5. Start server
```bash
# Development (auto-reload)
npm run dev

# Production
npm start
```

---

## API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/refresh` | Refresh access token |
| POST | `/api/auth/logout` | Logout |
| GET | `/api/auth/me` | Get current user (protected) |

### Devices
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/devices` | List user's devices |
| GET | `/api/devices/:id` | Get single device |
| POST | `/api/devices` | Create device |
| PUT | `/api/devices/:id` | Update device |
| DELETE | `/api/devices/:id` | Delete device |

### Health
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Server health check |

---

## WebSocket (Flutter)

Connect from Flutter using `web_socket_channel`:
```dart
final channel = WebSocketChannel.connect(
  Uri.parse('ws://your-server:3000?token=YOUR_JWT_TOKEN'),
);
```

Send/receive JSON messages.

---

## MQTT

The server auto-subscribes to `devices/#`.

Publish device data to: `devices/{deviceId}/status`

```json
{ "status": "online", "temperature": 25.3 }
```

---

## Flutter Auth Flow (Dart example)

```dart
// Login
final res = await http.post(
  Uri.parse('https://your-server/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);
final data = jsonDecode(res.body);
final accessToken = data['data']['accessToken'];

// Authenticated request
final devicesRes = await http.get(
  Uri.parse('https://your-server/api/devices'),
  headers: {'Authorization': 'Bearer $accessToken'},
);
```
