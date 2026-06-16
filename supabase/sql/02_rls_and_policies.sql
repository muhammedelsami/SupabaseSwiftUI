-- Row Level Security: every user can only touch their own notes.

alter table public.notes enable row level security;

create policy "notes_select_own" on public.notes
    for select using (auth.uid() = user_id);

create policy "notes_insert_own" on public.notes
    for insert with check (auth.uid() = user_id);

create policy "notes_update_own" on public.notes
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "notes_delete_own" on public.notes
    for delete using (auth.uid() = user_id);
