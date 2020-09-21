with source as (

    select *
    from {{ ref('stg_twitter_ads__tweet_url_tmp') }}

),

renamed as (

    select
    
        {{
            fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__tweet_url_tmp')),
                staging_columns=get_tweet_url_columns()
            )
        }}

    from source

)

select * from renamed