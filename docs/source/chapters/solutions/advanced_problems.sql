/*
.. |id_1| replace:: ``3363``
.. |id_2| replace:: ``14745``
.. |id_3| replace:: ``14441``
.. |id_4| replace:: ``6649``
.. |id_5| replace:: ``1175``
*/

ALTER TABLE configuration DROP COLUMN IF EXISTS penalty;

\o ad-7.txt

SELECT * FROM pgr_dijkstra(
    '
      SELECT gid AS id,
        source,
        target,
        cost_s AS cost,
        reverse_cost_s AS reverse_cost
      FROM ways
    ',
    14441,
    3363,
    directed := true);


\o ad-8.txt

SELECT * FROM pgr_dijkstra(
  '
    SELECT gid AS id,
      source,
      target,
      cost_s AS cost,
      reverse_cost_s AS reverse_cost
    FROM ways
  ',
  3363,
  14441,
  directed := true);


\o ad-9.txt


SELECT * FROM pgr_dijkstra(
  '
    SELECT gid AS id,
      source,
      target,
      cost_s / 3600 * 100 AS cost,
      reverse_cost_s / 3600 * 100 AS reverse_cost
    FROM ways
  ',
  3363,
  14441);

\o info-1.txt


SELECT tag_id, tag_key, tag_value FROM configuration ORDER BY tag_id;


\o info-2.txt


SELECT distinct tag_id, tag_key, tag_value
FROM ways JOIN configuration USING (tag_id)
ORDER BY tag_id;


\o ad-10.txt

ALTER TABLE configuration ADD COLUMN penalty FLOAT;
-- No penalty
UPDATE configuration SET penalty=1;


SELECT *
FROM pgr_dijkstra(
  '
    SELECT gid AS id,
        source,
        target,
        cost_s * penalty AS cost,
        reverse_cost_s * penalty AS reverse_cost
    FROM ways JOIN configuration
    USING (tag_id)
  ',
  14441,
  3363);

\o tmp.txt


-- Not including pedestrian ways
UPDATE configuration SET penalty=-1.0 WHERE tag_value IN ('steps','footway','pedestrian');
-- Penalizing with 5 times the costs
UPDATE configuration SET penalty=5 WHERE tag_value IN ('residential');
-- Encuraging the use of "fast" roads
UPDATE configuration SET penalty=0.5 WHERE tag_value IN ('tertiary');
UPDATE configuration SET penalty=0.3 WHERE tag_value
IN ('primary','primary_link',
    'trunk','trunk_link',
    'motorway','motorway_junction','motorway_link',
    'secondary');

\o ad-11.txt

SELECT * FROM pgr_dijkstra(
  '
    SELECT gid AS id,
        source,
        target,
        cost_s * penalty AS cost,
        reverse_cost_s * penalty AS reverse_cost
    FROM ways JOIN configuration
    USING (tag_id)
  ',
  14441,
  3363);

\o tmp.txt
\o

