-- Add firm_name column to claims table
ALTER TABLE claims 
ADD COLUMN IF NOT EXISTS firm_name TEXT;
