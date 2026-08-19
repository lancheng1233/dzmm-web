-- ===== 画师库存储/写入策略配置 =====
-- 在 Supabase SQL Editor 里执行

-- 1. artists 表：允许 anon(公开) 插入（供管理员上传用，密钥在前端把关）
drop policy if exists "admin insert artists" on public.artists;
create policy "allow insert artists"
on public.artists for insert
to anon, authenticated
with check (true);

-- 2. 存储桶：允许 anon 上传/覆盖图片
-- (需要先建好 artist-images 桶，已建)
insert into storage.buckets (id, name, public)
values ('artist-images', 'artist-images', true)
on conflict (id) do nothing;

-- 允许 anon 上传文件到 artist-images
drop policy if exists "allow anon upload images" on storage.objects;
create policy "allow anon upload images"
on storage.objects for insert
to anon, authenticated
with check (bucket_id = 'artist-images');

-- 允许 anon 覆盖(update)同名文件(upsert用)
drop policy if exists "allow anon update images" on storage.objects;
create policy "allow anon update images"
on storage.objects for update
to anon, authenticated
using (bucket_id = 'artist-images')
with check (bucket_id = 'artist-images');

-- 允许 anon 读取图片(公开)
drop policy if exists "allow anon read images" on storage.objects;
create policy "allow anon read images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'artist-images');
