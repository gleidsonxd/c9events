CREATE TABLE "schema_migrations" ("version" varchar NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "eventos" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "nome" varchar, "descricao" text, "data_ini" datetime, "data_fim" datetime, "usuario_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE INDEX "index_eventos_on_usuario_id" ON "eventos" ("usuario_id");
CREATE TABLE "usuarios" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "nome" varchar, "email" varchar, "matricula" varchar, "admin" boolean DEFAULT 'f', "tcoord" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "lugars" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "nome" varchar, "quantidade" integer);
CREATE TABLE "servicos" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "tempo" integer, "nome" varchar, "coord_id" integer);
CREATE INDEX "index_servicos_on_coord_id" ON "servicos" ("coord_id");
CREATE TABLE "eventos_servicos" ("servico_id" integer, "evento_id" integer);
CREATE INDEX "index_eventos_servicos_on_servico_id" ON "eventos_servicos" ("servico_id");
CREATE INDEX "index_eventos_servicos_on_evento_id" ON "eventos_servicos" ("evento_id");
CREATE TABLE "coords" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "nome" varchar, "email" varchar);
CREATE TABLE "eventos_lugars" ("lugar_id" integer, "evento_id" integer);
CREATE INDEX "index_eventos_lugars_on_lugar_id" ON "eventos_lugars" ("lugar_id");
CREATE INDEX "index_eventos_lugars_on_evento_id" ON "eventos_lugars" ("evento_id");
INSERT INTO schema_migrations (version) VALUES ('20160801230634');

INSERT INTO schema_migrations (version) VALUES ('20160808173643');

INSERT INTO schema_migrations (version) VALUES ('20160811170411');

INSERT INTO schema_migrations (version) VALUES ('20160811172234');

INSERT INTO schema_migrations (version) VALUES ('20160811172642');

INSERT INTO schema_migrations (version) VALUES ('20160815165611');

INSERT INTO schema_migrations (version) VALUES ('20160822170256');

