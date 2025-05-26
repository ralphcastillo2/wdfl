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

    import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({ status: 'ok' });
}
// This GET handler is a simple health check endpoint
// that returns a JSON response indicating the service is running.
// It can be used to verify that the API is operational.
// It does not interact with the database and is used for monitoring purposes.
// The POST handler is responsible for handling form submissions,

