-- 固化模板：GMV按渠道（关联维度表）拆解（表关联、指标口径已固化）
-- 适配指令：“近30天GMV按渠道趋势分析”
WITH metric_calc AS (
    SELECT
        dim_channel.channel_name AS 渠道名称,  -- 维度表补充渠道名称
        fact_polaris_daily.province AS 省份,
        fact_polaris_daily.dt AS 日期,
        SUM(fact_polaris_daily.gmv) AS gmv,  -- 固化GMV口径
        ROUND(IF(SUM(fact_polaris_daily.order_cnt)=0, 0, SUM(fact_polaris_daily.gmv)/SUM(fact_polaris_daily.order_cnt)), 2) AS price_per  -- 固化客单价口径
    FROM
        fact_polaris_daily
        LEFT JOIN dim_channel  -- 固化关联方式：LEFT JOIN
        ON fact_polaris_daily.channel = dim_channel.channel_name  -- 固化关联字段
    WHERE
        ${time_condition}  -- 动态时间参数
        AND dim_channel.channel_name IN ('电商', '门店', '分销')  -- 固化渠道枚举值
    GROUP BY dim_channel.channel_name, fact_polaris_daily.province, fact_polaris_daily.dt
)
SELECT
    渠道名称,
    省份,
    日期,
    gmv,
    price_per,
    ROUND(gmv/(SELECT SUM(gmv) FROM metric_calc), 4)*100 AS 占比
FROM metric_calc
ORDER BY 日期, 渠道名称;
