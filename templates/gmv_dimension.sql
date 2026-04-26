-- 固化模板：GMV/订单量按渠道+省份拆解（维度映射、枚举值已固化）
-- 适配指令：“2026-04-22 GMV环比下降15%，按渠道+省份拆解贡献”
WITH metric_calc AS (
    SELECT
        channel AS 渠道,  -- 固化维度映射：channel→渠道
        province AS 省份, -- 固化维度映射：province→省份
        dt AS 日期,
        SUM(gmv) AS gmv,  -- 固化GMV口径
        SUM(order_cnt) AS order_cnt  -- 固化订单量口径
    FROM fact_polaris_daily
    WHERE
        DATE_FORMAT(dt, '%Y-%m-%d') BETWEEN '${start_date}' AND '${end_date}'  -- 动态日期参数
        AND channel IN ('电商', '门店', '分销')  -- 固化渠道枚举值
        AND province IN (${province_list})  -- 动态省份参数
    GROUP BY channel, province, dt
)
SELECT
    渠道,
    省份,
    日期,
    gmv,
    order_cnt,
    ROUND(gmv/(SELECT SUM(gmv) FROM metric_calc), 4)*100 AS 占比,
    ROUND((gmv - LAG(gmv, 1) OVER(PARTITION BY 渠道, 省份 ORDER BY 日期))/LAG(gmv, 1) OVER(PARTITION BY 渠道, 省份 ORDER BY 日期)*100, 2) AS mom_rate
FROM metric_calc
ORDER BY 渠道, 省份, 日期;
