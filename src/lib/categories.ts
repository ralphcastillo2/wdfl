import { connectToDatabase } from './mongodb'
import { Category } from '@/types/Category'
import { WithId, Document } from 'mongodb'

export async function getAllCategories(): Promise<Category[]> {
  const connection = await connectToDatabase()
  
  if (!connection || !connection.db) {
    throw new Error('Database connection failed')
  }

  const categories = await connection.db.collection('categories').find({}).toArray()
  return categories.map(category => ({
    _id: category._id.toString(),
    name: category.name as string,
    slug: category.slug as string,
    description: category.description as string
  }))
} 