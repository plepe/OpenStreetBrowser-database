-- Drop all primary keys and indexes to improve load speed.
ALTER TABLE nodes DROP CONSTRAINT pk_nodes;
ALTER TABLE ways DROP CONSTRAINT pk_ways;
ALTER TABLE way_nodes DROP CONSTRAINT pk_way_nodes;
ALTER TABLE relations DROP CONSTRAINT pk_relations;
ALTER TABLE relation_members DROP CONSTRAINT pk_relation_members;
DROP INDEX idx_node_tags_node_id;
DROP INDEX idx_way_tags_way_id;
DROP INDEX idx_way_nodes_node_id;
DROP INDEX idx_relation_tags_relation_id;

-- Import the table data from the data files using the fast COPY method.
\copy users FROM 'pgimport/users.txt'
\copy nodes FROM 'pgimport/nodes.txt'
\copy node_tags FROM 'pgimport/node_tags.txt'
\copy ways FROM 'pgimport/ways.txt'
\copy way_tags FROM 'pgimport/way_tags.txt'
\copy way_nodes FROM 'pgimport/way_nodes.txt'
\copy relations FROM 'pgimport/relations.txt'
\copy relation_tags FROM 'pgimport/relation_tags.txt'
\copy relation_members FROM 'pgimport/relation_members.txt'

-- Add the primary keys and indexes back again (except the way bbox index).
ALTER TABLE ONLY nodes ADD CONSTRAINT pk_nodes PRIMARY KEY (id);
ALTER TABLE ONLY ways ADD CONSTRAINT pk_ways PRIMARY KEY (id);
ALTER TABLE ONLY way_nodes ADD CONSTRAINT pk_way_nodes PRIMARY KEY (way_id, sequence_id);
ALTER TABLE ONLY relations ADD CONSTRAINT pk_relations PRIMARY KEY (id);
ALTER TABLE ONLY relation_members ADD CONSTRAINT pk_relation_members PRIMARY KEY (relation_id, sequence_id);
CREATE INDEX idx_node_tags_node_id ON node_tags USING btree (node_id);
CREATE INDEX idx_way_tags_way_id ON way_tags USING btree (way_id);
CREATE INDEX idx_way_nodes_node_id ON way_nodes USING btree (node_id);
CREATE INDEX idx_relation_tags_relation_id ON relation_tags USING btree (relation_id);

-- Perform database maintenance due to large database changes.
VACUUM ANALYZE;
