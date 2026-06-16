# Premium Notes — SwiftUI + Supabase

A dark-mode-only iOS notes app backed by Supabase (Auth, PostgREST, Storage),
built with SwiftUI and MVVM + Clean Architecture.

## Architecture

```
SupabaseSwiftUI/
├── App/            SupabaseConfig, AppDependencies (SupabaseClient singleton), @main
├── Domain/         Models, Resource<T>, repository protocols
├── Data/           Repository implementations (Supabase SDK)
├── Presentation/   SessionManager, ViewModels (@Observable), SwiftUI screens
├── UI/Theme/       Color & font tokens
└── UI/Components/  Reusable views (fields, buttons, loading overlay)
supabase/
├── sql/            Schema, RLS policies, storage policies
└── functions/      delete-user-account Edge Function
```

Dependencies (Swift Package Manager): `supabase-swift`, `Kingfisher`.

## Setup

### 1. Supabase credentials (kept out of git)

Credentials live in **`Secrets.xcconfig`**, which is git-ignored — they are never
committed. The project's build configurations read it via `baseConfigurationReference`,
and the values flow into `Info.plist` (`SUPABASE_HOST`, `SUPABASE_ANON_KEY`), which
`App/SupabaseConfig.swift` reads at runtime.

```bash
cp Secrets.example.xcconfig Secrets.xcconfig
```

Then edit `Secrets.xcconfig` with values from Supabase Dashboard → Project Settings → API:

```
SUPABASE_HOST = abcdxyz.supabase.co        # host only — NO "https://"
SUPABASE_ANON_KEY = eyJhbGci...            # anon / public key
```

> ⚠️ `.xcconfig` treats `//` as a comment, so enter the **host only**; the app
> prepends `https://` in code.
>
> Until you set real values, the app builds but shows a clear fatal-error on launch
> telling you to edit `Secrets.xcconfig`. Only `Secrets.example.xcconfig` (a template
> with placeholders) is committed.

### 2. Database & storage

Run the SQL scripts in order in the Supabase SQL editor:

1. `supabase/sql/01_notes_schema.sql` — table, indexes, `updated_at` trigger
2. `supabase/sql/02_rls_and_policies.sql` — row-level security
3. `supabase/sql/03_storage_policies.sql` — `notes-images` bucket + per-user policies

Storage path convention: `<userId>/<noteId>/image.jpg`. On delete/replace the
Storage object is always removed **before** the database row.

### 3. Account deletion Edge Function

```bash
supabase functions deploy delete-user-account
```

The app removes the user's notes and images first, then invokes this function,
which deletes the auth user with the service-role key.

### 4. Password reset deep link

The URL scheme `notesapp` is registered in `Info.plist`; reset emails redirect to
`notesapp://reset-password`, handled in `SupabaseSwiftUIApp.onOpenURL`.

## Requirements

- Xcode 26+, iOS 17+ (project deployment target currently 26.4).
