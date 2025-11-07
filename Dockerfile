# 构建阶段：使用包含 pnpm 的 Node 镜像
FROM node:22.21-alpine3.21 AS builder
WORKDIR /app

# 更换 npm 源（例如使用淘宝镜像）
RUN npm config set registry https://registry.npmmirror.com/

# 安装 pnpm（若基础镜像未预装）
RUN npm install -g pnpm

# 复制依赖配置文件
COPY package.json pnpm-lock.yaml ./

# 安装依赖（使用 pnpm 高效安装，仅安装生产依赖）
RUN pnpm install --frozen-lockfile --prod

# 复制源代码并构建
COPY . .
RUN pnpm build  # 假设 NestJS 构建命令为 pnpm build

# 运行阶段
FROM node:22.21-alpine3.21
WORKDIR /app

# 安装 pnpm（运行阶段可能需要，视启动命令而定）
RUN npm install -g pnpm

# 复制构建产物和依赖
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml

EXPOSE 3001
CMD ["pnpm", "start"]  # 使用 pnpm 启动