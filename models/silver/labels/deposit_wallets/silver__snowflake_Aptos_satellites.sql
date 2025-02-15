{{ config(
    materialized = 'incremental',
    unique_key = "address",
    incremental_strategy = 'delete+insert',
) }}

WITH aptos_transfers AS (

    SELECT
        block_timestamp,
        from_address,
        to_address,
        amount
    FROM
        {{ source(
            'aptos_core',
            'ez_native_transfers'
        ) }}

{% if is_incremental() %}
WHERE
    block_timestamp > CURRENT_DATE - 10
{% endif %}
),
distributor_cex AS (
    -- THIS STATEMENT FINDS KNOWN CEX LABELS WITHIN THE BRONZE ADDRESS LABELS TABLE
    SELECT
        system_created_at,
        insert_date,
        blockchain,
        address,
        creator,
        label_type AS l1_label,
        label_subtype AS l2_label,
        address_name,
        project_name
    FROM
        {{ ref('silver__address_labels') }}
    WHERE
        blockchain = 'aptos'
        AND l1_label = 'cex'
        AND l2_label = 'hot_wallet'
        AND delete_flag IS NULL
),
possible_sats AS (
    -- THIS STATEMENT LOCATES POTENTIAL SATELLITE WALLETS BASED ON DEPOSIT BEHAVIOR
    SELECT
        DISTINCT *
    FROM
        (
            SELECT
                DISTINCT dc.system_created_at,
                dc.insert_date,
                dc.blockchain,
                xfer.from_address AS address,
                dc.creator,
                dc.address_name,
                dc.project_name,
                dc.l1_label,
                'deposit_wallet' AS l2_label,
                COUNT(
                    DISTINCT project_name
                ) over(
                    PARTITION BY dc.blockchain,
                    xfer.from_address
                ) AS project_count -- how many projects has each from address sent to
            FROM
                aptos_transfers xfer
                JOIN distributor_cex dc
                ON dc.address = xfer.to_address
            WHERE
                amount > 0
            GROUP BY
                1,
                2,
                3,
                4,
                5,
                6,
                7,
                8,
                9
        )
),
real_sats AS (
    SELECT
        from_address,
        COUNT(DISTINCT COALESCE(project_name, 'blunts')) AS project_count
    FROM
        aptos_transfers xfer
        LEFT OUTER JOIN distributor_cex dc
        ON dc.address = xfer.to_address
    WHERE
        amount > 0
        AND from_address IN (
            SELECT
                address
            FROM
                possible_sats
        )
    GROUP BY
        from_address
),
exclusive_sats AS (
    SELECT
        DISTINCT from_address AS address
    FROM
        real_sats
    WHERE
        project_count = 1
    GROUP BY
        1
),
final_base AS(
    SELECT
        DISTINCT CURRENT_TIMESTAMP AS system_created_at,
        CURRENT_TIMESTAMP AS insert_date,
        blockchain,
        e.address,
        creator,
        l1_label,
        l2_label,
        project_name,
        CONCAT(
            project_name,
            ' deposit_wallet'
        ) AS address_name
    FROM
        exclusive_sats e
        JOIN possible_sats p
        ON e.address = p.address
)
SELECT
    DISTINCT f.system_created_at,
    f.insert_date,
    f.blockchain,
    f.address,
    f.creator,
    f.l1_label,
    f.l2_label,
    f.address_name,
    f.project_name,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    {{ dbt_utils.generate_surrogate_key(['f.address']) }} AS snowflake_aptos_satellites_id,
    '{{ invocation_id }}' AS _invocation_id
FROM
    final_base f
    LEFT JOIN {{ ref('silver__address_labels') }} A
    ON f.address = A.address
    AND A.blockchain = 'aptos'
    AND A.delete_flag IS NULL
WHERE
    A.address IS NULL
