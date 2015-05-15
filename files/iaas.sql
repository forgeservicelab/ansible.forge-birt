--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE capasity (
    date date,
    vcpus bigint,
    memory_mb bigint,
    volume_gb bigint
);

CREATE TABLE quota (
    date date,
    project text,
    instances bigint,
    vcpus bigint,
    memory_mb bigint,
    fixed_ips bigint,
    floating_ips bigint,
    keypairs bigint,
    sec_groups bigint,
    sec_group_rules bigint,
    volumes bigint,
    volume_gb bigint
);

CREATE TABLE usage (
    date date,
    instance_id text,
    vcpus bigint,
    memory_mb bigint,
    flavor text,
    project text,
    state text,
    start text,
    "end" text
);

CREATE TABLE volumeusage (
    date date,
    project text,
    volumes bigint DEFAULT 0 NOT NULL,
    volume_gb bigint DEFAULT 0 NOT NULL
);
