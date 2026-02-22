import { createClient } from '@supabase/supabase-js';

// Replace with your actual Supabase URL and Anon Key
const SUPABASE_URL = 'your-supabase-url';
const SUPABASE_ANON_KEY = 'your-anon-key';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export default supabase;