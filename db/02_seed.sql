-- db/02_seed.sql
-- Sample data for Riffr Prototype 2

-- 3 sample users
insert into users (user_id, email, username, password_hash)
values
  ('11111111-1111-1111-1111-111111111111', 'lana@example.com', 'lana_rap', 'hash_lana'),
  ('22222222-2222-2222-2222-222222222222', 'marco@example.com', 'marco_beats', 'hash_marco'),
  ('33333333-3333-3333-3333-333333333333', 'ayana@example.com', 'ayana_vocals', 'hash_ayana');

-- Profiles
insert into profiles (user_id, display_name, bio, location_text)
values
  ('11111111-1111-1111-1111-111111111111', 'Lana R.', 'Hobbyist rapper looking for producers.', 'Los Angeles, CA'),
  ('22222222-2222-2222-2222-222222222222', 'Marco B.', 'Bedroom producer focused on trap & hip-hop.', 'Atlanta, GA'),
  ('33333333-3333-3333-3333-333333333333', 'Ayana V.', 'R&B vocalist with some studio experience.', 'Chicago, IL');

-- Roles
insert into roles (name) values
  ('rapper'),
  ('producer'),
  ('vocalist'),
  ('songwriter'),
  ('instrumentalist')
on conflict do nothing;

-- Genres
insert into genres (name) values
  ('hip-hop'),
  ('trap'),
  ('r&b'),
  ('pop')
on conflict do nothing;

-- Skills
insert into skills (name) values
  ('lyric-writing'),
  ('beat-making'),
  ('mixing'),
  ('topline-melodies')
on conflict do nothing;

-- Lana: rapper, hip-hop, lyric-writing
insert into user_role (user_role_id, user_id, role_id)
select gen_random_uuid(), '11111111-1111-1111-1111-111111111111', role_id
from roles where name = 'rapper';

insert into user_genre (user_genre_id, user_id, genre_id)
select gen_random_uuid(), '11111111-1111-1111-1111-111111111111', genre_id
from genres where name = 'hip-hop';

insert into user_skill (user_skill_id, user_id, skill_id)
select gen_random_uuid(), '11111111-1111-1111-1111-111111111111', skill_id
from skills where name = 'lyric-writing';

-- Marco: producer, trap, beat-making, mixing
insert into user_role (user_role_id, user_id, role_id)
select gen_random_uuid(), '22222222-2222-2222-2222-222222222222', role_id
from roles where name = 'producer';

insert into user_genre (user_genre_id, user_id, genre_id)
select gen_random_uuid(), '22222222-2222-2222-2222-222222222222', genre_id
from genres where name = 'trap';

insert into user_skill (user_skill_id, user_id, skill_id)
select gen_random_uuid(), '22222222-2222-2222-2222-222222222222', skill_id
from skills where name in ('beat-making', 'mixing');

-- Ayana: vocalist, r&b, topline-melodies
insert into user_role (user_role_id, user_id, role_id)
select gen_random_uuid(), '33333333-3333-3333-3333-333333333333', role_id
from roles where name = 'vocalist';

insert into user_genre (user_genre_id, user_id, genre_id)
select gen_random_uuid(), '33333333-3333-3333-3333-333333333333', genre_id
from genres where name = 'r&b';

insert into user_skill (user_skill_id, user_id, skill_id)
select gen_random_uuid(), '33333333-3333-3333-3333-333333333333', skill_id
from skills where name = 'topline-melodies';

-- Audio previews
insert into audio_media (user_id, file_url, mime_type, duration_seconds)
values
  ('11111111-1111-1111-1111-111111111111', 'https://example.com/audio/lana_demo.mp3', 'audio/mpeg', 45),
  ('22222222-2222-2222-2222-222222222222', 'https://example.com/audio/marco_beat.mp3', 'audio/mpeg', 60),
  ('33333333-3333-3333-3333-333333333333', 'https://example.com/audio/ayana_hook.mp3', 'audio/mpeg', 35);

-- External links
insert into external_links (user_id, platform, url)
values
  ('11111111-1111-1111-1111-111111111111', 'soundcloud', 'https://soundcloud.com/lana_rap'),
  ('22222222-2222-2222-2222-222222222222', 'spotify', 'https://open.spotify.com/artist/marco_beats'),
  ('33333333-3333-3333-3333-333333333333', 'soundcloud', 'https://soundcloud.com/ayana_vocals');

-- Match between Lana and Marco
insert into matches (match_id, user_a_id, user_b_id)
values (
  '44444444-4444-4444-4444-444444444444',
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222'
);

-- Messages in that match
insert into messages (match_id, sender_user_id, recipient_user_id, body_text)
values
  ('44444444-4444-4444-4444-444444444444',
   '11111111-1111-1111-1111-111111111111',
   '22222222-2222-2222-2222-222222222222',
   'Hey, I loved your latest trap beat, want to collab?'),
  ('44444444-4444-4444-4444-444444444444',
   '22222222-2222-2222-2222-222222222222',
   '11111111-1111-1111-1111-111111111111',
   'For sure! Send me a topline idea.');

-- Saved profile: Lana saves Ayana
insert into saved_profiles (saver_user_id, saved_user_id)
values (
  '11111111-1111-1111-1111-111111111111',
  '33333333-3333-3333-3333-333333333333'
);

-- Notifications
insert into notifications (user_id, notification_type, payload)
values
  ('11111111-1111-1111-1111-111111111111', 'new_match',
   '{"with_user_id": "22222222-2222-2222-2222-222222222222"}'),
  ('22222222-2222-2222-2222-222222222222', 'new_message',
   '{"from_user_id": "11111111-1111-1111-1111-111111111111"}');

-- User stats
insert into user_stats (user_id, total_matches_bucket, last_active_at)
values
  ('11111111-1111-1111-1111-111111111111', '1-9', now()),
  ('22222222-2222-2222-2222-222222222222', '1-9', now()),
  ('33333333-3333-3333-3333-333333333333', '0',   now());
