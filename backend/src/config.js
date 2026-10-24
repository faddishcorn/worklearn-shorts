import path from 'node:path'

const backendDir = path.resolve(import.meta.dirname, '..')
const fromBackend = (p) => path.resolve(backendDir, p)

export const config = {
	backendDir,
	port: Number(process.env.Port) || 3000,
	dbPath : fromBackend(process.env.DB_PATH || './data/app.db'),
	uploadDir : fromBackend(process.env.UPLOAD_DIR || './upload'),
	authSecret : process.env.AUTH_SECRET || '',
	allowedOrigin : process.env.ALLOWED_ORIGIN || 'http://localhost:5173',
}
