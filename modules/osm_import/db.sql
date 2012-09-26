create index node_tags_k_id on node_tags(k, node_id);
create index way_tags_k_id on way_tags(k, way_id);
create index relation_tags_k_id on relation_tags(k, relation_id);

create index relations_members_pk on relation_members (relation_id);
create index relations_members_mem on relation_members (member_id);
create index relations_members_type on relation_members (member_type);
create index relations_members_role on relation_members (member_role);

create index way_nodes_seq_id on way_nodes("sequence_id");
