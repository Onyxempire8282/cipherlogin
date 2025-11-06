-- Step 1: Add updated_at column to claims table
ALTER TABLE claims 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Step 2: Create a trigger to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_claims_updated_at BEFORE UPDATE ON claims
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Step 3: Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    claim_id UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('ASSIGNED', 'STATUS_CHANGED', 'CANCELED', 'UPDATED')),
    message TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 4: Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- Step 5: Enable RLS (Row Level Security)
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Step 6: Create RLS policies for notifications
-- Users can only see their own notifications
CREATE POLICY "Users can view their own notifications"
ON notifications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can mark their own notifications as read
CREATE POLICY "Users can update their own notifications"
ON notifications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- System can insert notifications (we'll do this from the app)
CREATE POLICY "Allow insert notifications"
ON notifications FOR INSERT
TO authenticated
WITH CHECK (true);

-- Step 7: Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_claim_id UUID,
    p_type TEXT,
    p_message TEXT,
    p_old_value TEXT DEFAULT NULL,
    p_new_value TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO notifications (user_id, claim_id, type, message, old_value, new_value)
    VALUES (p_user_id, p_claim_id, p_type, p_message, p_old_value, p_new_value)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 8: Optional - Clean up old notifications (older than 30 days)
-- Run this periodically or set up a cron job
-- DELETE FROM notifications WHERE created_at < NOW() - INTERVAL '30 days';
