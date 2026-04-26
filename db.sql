CREATE DATABASE IF NOT EXISTS polaris_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE polaris_db;

-- 事实表：北极星指标日度数据
CREATE TABLE fact_polaris_daily (
    dt DATE NOT NULL COMMENT '日期',
    channel VARCHAR(32) COMMENT '渠道',
    province VARCHAR(32) COMMENT '省份',
    category VARCHAR(32) COMMENT '品类',
    customer_type VARCHAR(16) COMMENT '新老客',
    gmv DECIMAL(18,2) COMMENT 'GMV(北极星指标)',
    order_cnt INT COMMENT '订单量',
    user_cnt INT COMMENT '付费用户数',
    price_per DECIMAL(10,2) COMMENT '客单价',
    PRIMARY KEY (dt, channel, province, category, customer_type)
) COMMENT '北极星指标日事实表';

-- 维度表（可选，规范枚举）
CREATE TABLE dim_channel (
    channel_code VARCHAR(32) PRIMARY KEY,
    channel_name VARCHAR(64)
) COMMENT '渠道维度表';
