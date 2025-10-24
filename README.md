# EProject - Microservices E-Commerce System

## Mô tả hệ thống

Hệ thống EProject là một ứng dụng thương mại điện tử được xây dựng theo kiến trúc microservices, giải quyết bài toán quản lý sản phẩm, đặt hàng và xác thực người dùng một cách phân tán và có khả năng mở rộng cao.

## Kiến trúc hệ thống

### Số lượng dịch vụ: 4 services chính + 2 services hỗ trợ

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway (Port 3000)                   │
│                     Điểm vào duy nhất của hệ thống              │
└──────────────┬──────────────┬────────────────┬─────────────────┘
               │              │                │
       ┌───────▼─────┐  ┌────▼─────┐  ┌──────▼────────┐
       │Auth Service │  │  Product   │  │Order Service  │
       │ (Port 7070) │  │  Service   │  │ (Port 9090)   │
       │             │  │(Port 8080) │  │               │
       └─────────────┘  └────┬───────┘  └───────┬───────┘
                             │                  │
                    ┌────────▼──────────────────▼────────┐
                    │         RabbitMQ (Port 5672)       │
                    │     Message Broker - Giao tiếp     │
                    │         giữa các services          │
                    └────────────────────────────────────┘
                                   │
                    ┌──────────────▼─────────────────────┐
                    │      MongoDB (Port 27017)          │
                    │   Database - Lưu trữ dữ liệu      │
                    └────────────────────────────────────┘
```

## Ý nghĩa từng dịch vụ

### 1. API Gateway (Port 3000)
- **Chức năng**: Điểm vào duy nhất của hệ thống, định tuyến requests đến các services phù hợp
- **Vai trò**: Reverse proxy, load balancer, xử lý CORS
- **Công nghệ**: Express.js

### 2. Auth Service (Port 7070)
- **Chức năng**: Xử lý xác thực người dùng, đăng ký, đăng nhập
- **Vai trò**: Quản lý JWT tokens, bảo mật thông tin người dùng
- **Công nghệ**: Express.js, JWT, bcrypt
- **Database**: MongoDB (users collection)

### 3. Product Service (Port 8080)
- **Chức năng**: Quản lý sản phẩm, tạo đơn hàng
- **Vai trò**: CRUD operations cho products, khởi tạo orders
- **Công nghệ**: Express.js, Mongoose
- **Database**: MongoDB (products collection)
- **Message Queue**: Publish orders to RabbitMQ

### 4. Order Service (Port 9090)
- **Chức năng**: Xử lý đơn hàng
- **Vai trò**: Nhận orders từ queue, xử lý và lưu trữ
- **Công nghệ**: Express.js, Mongoose
- **Database**: MongoDB (orders collection)
- **Message Queue**: Consume orders from RabbitMQ

### 5. RabbitMQ (Port 5672, 15672)
- **Chức năng**: Message broker cho giao tiếp bất đồng bộ
- **Vai trò**: Decoupling services, đảm bảo reliability
- **Management UI**: Port 15672

### 6. MongoDB (Port 27017)
- **Chức năng**: Database NoSQL
- **Vai trò**: Lưu trữ dữ liệu users, products, orders
- **Collections**: users, products, orders

## Các mẫu thiết kế được sử dụng

### 1. **Microservices Pattern**
- Chia nhỏ hệ thống thành các services độc lập
- Mỗi service có database riêng (Database per Service)
- Dễ dàng scale và maintain

### 2. **API Gateway Pattern**
- Single entry point cho tất cả requests
- Routing, authentication, load balancing
- Giảm complexity cho client

### 3. **Event-Driven Architecture**
- Sử dụng RabbitMQ để giao tiếp giữa services
- Asynchronous communication
- Loosely coupled services

### 4. **Repository Pattern**
- Tách biệt business logic và data access
- Các Repository classes xử lý database operations
- Dễ dàng testing và thay đổi database

### 5. **Middleware Pattern**
- isAuthenticated middleware cho authorization
- Error handling middleware
- Logging middleware

## Cách các dịch vụ giao tiếp

### 1. **Synchronous Communication (HTTP/REST)**
```
Client → API Gateway → Auth Service (POST /register, /login)
Client → API Gateway → Product Service (GET /products, POST /products, GET /products/:id)
```

### 2. **Asynchronous Communication (Message Queue)**
```
Product Service → RabbitMQ (orders queue) → Order Service
Order Service → RabbitMQ (products queue) → Product Service
```

### Flow đặt hàng:
1. Client gửi POST request đến `/products/buy`
2. Product Service validate và publish message lên RabbitMQ queue "orders"
3. Order Service consume message từ queue "orders"
4. Order Service xử lý và lưu order vào database
5. Order Service publish kết quả lên queue "products"
6. Product Service nhận kết quả và trả về cho client

## Cài đặt và chạy dự án

### Yêu cầu hệ thống
- Node.js >= 18
- Docker và Docker Compose
- MongoDB
- RabbitMQ

### Chạy với Docker Compose

```bash
# Clone repository
git clone <repository-url>
cd EProject

# Build và chạy tất cả services
docker-compose up --build

# Chạy ở chế độ background
docker-compose up -d --build

# Xem logs
docker-compose logs -f

# Dừng các services
docker-compose down

# Dừng và xóa volumes
docker-compose down -v
```

### Chạy từng service riêng lẻ (Development)

```bash
# Cài đặt dependencies cho root project
npm install

# Cài đặt dependencies cho từng service
cd auth && npm install && cd ..
cd product && npm install && cd ..
cd order && npm install && cd ..
cd api-gateway && npm install && cd ..

# Chạy MongoDB và RabbitMQ
docker run -d -p 27017:27017 --name mongodb mongo:6
docker run -d -p 5672:5672 -p 15672:15672 --name rabbitmq rabbitmq:3-management-alpine

# Chạy từng service (mở terminal riêng cho mỗi service)
cd auth && npm start
cd product && npm start
cd order && npm start
cd api-gateway && npm start
```

## Testing với POSTMAN

### 1. Đăng ký tài khoản
```
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```

### 2. Đăng nhập
```
POST http://localhost:3000/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}

Response: { "token": "eyJhbGc..." }
```

### 3. Tạo sản phẩm mới
```
POST http://localhost:3000/products
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Product 1",
  "description": "Description of product 1",
  "price": 100000,
  "stock": 50
}
```

### 4. Lấy danh sách sản phẩm
```
GET http://localhost:3000/products
Authorization: Bearer <token>
```

### 5. Lấy thông tin sản phẩm theo ID
```
GET http://localhost:3000/products/<product_id>
Authorization: Bearer <token>
```

### 6. Đặt hàng
```
POST http://localhost:3000/products/buy
Authorization: Bearer <token>
Content-Type: application/json

{
  "ids": ["<product_id_1>", "<product_id_2>"]
}
```

## Testing với Docker

Khi test với Docker, đảm bảo rằng POSTMAN đang gọi đến các services đang chạy trong Docker:

```bash
# Kiểm tra các containers đang chạy
docker ps

# Kiểm tra logs của từng service
docker logs eproject-gateway
docker logs eproject-auth
docker logs eproject-product
docker logs eproject-order

# Test endpoint
curl http://localhost:3000/products -H "Authorization: Bearer <token>"
```

## CI/CD với GitHub Actions

### Setup
1. Fork/Clone repository về GitHub
2. Thêm secrets trong GitHub repository settings:
   - `DOCKER_USERNAME`: Docker Hub username
   - `DOCKER_PASSWORD`: Docker Hub password

### Workflow
- **Push to main/master**: Chạy tests → Build Docker images → Push to Docker Hub
- **Pull Request**: Chỉ chạy tests

### Pipeline stages:
1. **Test**: Chạy unit tests và integration tests
2. **Build**: Build Docker images cho tất cả services
3. **Deploy**: Push images lên Docker Hub

## Chạy tests

```bash
# Chạy tất cả tests
npm test

# Chạy tests cho service cụ thể
cd product && npm test
cd auth && npm test
```

## Cấu trúc thư mục

```
EProject/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions workflow
├── api-gateway/                # API Gateway service
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
├── auth/                       # Authentication service
│   ├── src/
│   │   ├── app.js
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   └── middlewares/
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
├── product/                    # Product service
│   ├── src/
│   │   ├── app.js
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── routes/
│   │   ├── services/
│   │   └── utils/
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
├── order/                      # Order service
│   ├── src/
│   │   ├── app.js
│   │   ├── models/
│   │   └── utils/
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
├── docker-compose.yml          # Docker Compose configuration
├── package.json                # Root package.json
└── README.md                   # This file
```

## Troubleshooting

### Vấn đề với MongoDB connection
```bash
# Kiểm tra MongoDB đang chạy
docker logs eproject-mongodb

# Reset MongoDB
docker-compose down -v
docker-compose up -d mongodb
```

### Vấn đề với RabbitMQ
```bash
# Kiểm tra RabbitMQ đang chạy
docker logs eproject-rabbitmq

# Truy cập RabbitMQ Management UI
http://localhost:15672
Username: guest
Password: guest
```

### Services không kết nối được
```bash
# Kiểm tra network
docker network ls
docker network inspect eproject_eproject-network

# Restart tất cả services
docker-compose restart
```

## Contributors

- Sinh viên thực hiện dự án

## License

ISC
