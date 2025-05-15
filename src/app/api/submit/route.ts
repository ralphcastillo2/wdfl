import { connectToDatabase, getConnectionStatus } from '@/lib/mongodb';
import { NextResponse } from 'next/server';
import mongoose from 'mongoose';

let connectionInitialized = false;

async function ensureConnection() {
  if (!connectionInitialized) {
    const connection = await connectToDatabase();
    if (!connection) {
      return null;
    }
    connectionInitialized = true;
  }
  
  if (!getConnectionStatus()) {
    const connection = await connectToDatabase();
    if (!connection) {
      return null;
    }
  }
  
  return true;
}

export async function POST(request: Request) {
  try {
    const connectionStatus = await ensureConnection();
    if (!connectionStatus) {
      return NextResponse.json(
        { success: false, error: 'Database connection not available' },
        { status: 503 }
      );
    }
    
    const db = mongoose.connection.db;
    if (!db) {
      throw new Error('Database connection not established');
    }
    
    const collection = db.collection('submissions');
    const data = await request.json();
    const result = await collection.insertOne({
      ...data,
      createdAt: new Date()
    });

    return NextResponse.json({ success: true, id: result.insertedId });
  } catch (error) {
    console.error('Error in submission:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to submit form' },
      { status: 500 }
    );
  }
} 