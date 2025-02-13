{{ config(
  materialized = 'view'
) }}

SELECT
  'axelar' AS blockchain,
  block_id,
  block_timestamp,
  tx_id,
  tx_succeeded,
  voter,
  proposal_id,
  vote_option,
  vote_weight,
  NULL AS memo,
  COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
  COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
  {{ dbt_utils.generate_surrogate_key(['blockchain','tx_id','proposal_id','voter','vote_option']) }} AS fact_governance_votes_id
FROM
  {{ source(
    'axelar_gov',
    'fact_governance_votes'
  ) }}
UNION ALL
SELECT
  'cosmos' AS blockchain,
  block_id,
  block_timestamp,
  tx_id,
  tx_succeeded,
  voter,
  proposal_id,
  vote_option,
  vote_weight,
  NULL AS memo,
  COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
  COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
  {{ dbt_utils.generate_surrogate_key(['blockchain','tx_id','proposal_id','voter','vote_option']) }} AS fact_governance_votes_id
FROM
  {{ source(
    'cosmos_gov',
    'fact_governance_votes'
  ) }}
UNION ALL
SELECT
  'osmosis' AS blockchain,
  block_id,
  block_timestamp,
  tx_id,
  tx_succeeded,
  voter,
  proposal_id,
  vote_option,
  vote_weight,
  memo,
  COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
  COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
  {{ dbt_utils.generate_surrogate_key(['blockchain','tx_id','proposal_id','voter','vote_option']) }} AS fact_governance_votes_id
FROM
  {{ source(
    'osmosis_gov',
    'fact_governance_votes'
  ) }}
