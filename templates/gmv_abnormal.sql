-- 固化模板：GMV异动分析（指标口径、异动阈值已固化）
-- 适配指令：“近7天GMV按日统计，判断是否有环比超±10%的异动”
WITH metric_calc AS (
    SELECT
        dt,
        ${channel_list:channel} AS channel,  -- 动态参数，OpenClaw填充渠道
        ${province_list:province} AS province,  -- 动态参数，OpenClaw填充省份
        SUM(gmv) AS gmv,  -- 固化GMV口径
        SUM(order_cnt) AS order_cnt,  -- 固化订单量口径
        ROUND(IF(SUM(order_cnt)=0, 0, SUM(gmv)/SUM(order_cnt)), 2) AS price_per  -- 固化客单价+异常处理
    FROM fact_polaris_daily
    WHERE ${time_condition}  -- 动态时间参数，OpenClaw按指令填充（如近7天）
    GROUP BY dt, channel, province
)
SELECT
    dt,
    SUM(gmv) AS daily_gmv,
    LAG(SUM(gmv), 1) OVER(ORDER BY dt) AS gmv_prev_day,
    ROUND((SUM(gmv) - LAG(SUM(gmv), 1) OVER(ORDER BY dt))/LAG(SUM(gmv), 1) OVER(ORDER BY dt)*100, 2) AS mom_rate,
    -- 固化异动阈值：环比绝对值>10%视为异动
    IF(ABS((SUM(gmv) - LAG(SUM(gmv), 1) OVER(ORDER BY dt))/LAG(SUM(gmv), 1) OVER(ORDER BY dt)*100) > 10, '是异动', '正常') AS is_abnormal
FROM metric_calc
GROUP BY dt
ORDER BY dt;
