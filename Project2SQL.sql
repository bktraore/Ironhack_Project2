create database project2;
use project2;
select * from regions;
select * from unemployment_female;

create temporary table wbapi_max_and_mins
select max(f.unemployment_fem) as max_f, min(f.unemployment_fem) as min_f,
max(t.unemployment_tot) as max_t, min(t.unemployment_tot) as min_t,
max(y.unemployment_youth) as max_y, min(y.unemployment_youth) as min_y
from unemployment_female as f
left join unemployment_tot as t on t.economy = f.economy
left join unemployment_youth as y on y.economy = f.economy;

select * from wbapi_max_and_mins;

create temporary table wbapi_indexes
select r.id as id, r.name as name, ((w.max_f-f.unemployment_fem)/(w.max_f-w.min_f)) as index_fem,
((w.max_t-t.unemployment_tot)/(w.max_t-w.min_t)) as index_tot,
((w.max_y-y.unemployment_youth)/(w.max_y-w.min_y)) as index_youth
from unemployment_female as f
left join regions as r on f.economy = r.id
left join unemployment_tot as t on t.economy = f.economy
left join unemployment_youth as y on y.economy = f.economy
left join wbapi_max_and_mins as w on true;

select * from wbapi_indexes;

select * from employment_with_tertiary;

create temporary table oecd_max_and_mins
select max(b.Value) as max_b, min(b.Value) as min_b,
max(s.Value) as max_s, min(s.Value) as min_s,
max(t.Value) as max_t, min(t.Value) as min_t
from employment_with_basics as b
left join employment_with_secondary as s on b.ï»¿LOCATION = s.ï»¿LOCATION
left join employment_with_tertiary as t on b.ï»¿LOCATION = t.ï»¿LOCATION
where b.TIME = 2021 and s.TIME = 2021 and t.TIME = 2021;

select * from oecd_max_and_mins;

create temporary table oecd_indexes
select r.id as id, r.name as name, (b.Value - o.min_b)/(o.max_b-o.min_b) as index_basics,
(s.Value - o.min_s)/(o.max_s-o.min_s) as index_secondary,
(t.Value - o.min_t)/(o.max_t-o.min_t) as index_tertiary
from unemployment_female as f
left join regions as r on f.economy = r.id
left join employment_with_basics as b on b.ï»¿LOCATION = r.id
left join employment_with_secondary as s on s.ï»¿LOCATION = r.id
left join employment_with_tertiary as t on t.ï»¿LOCATION = r.id
left join oecd_max_and_mins as o on true
where b.TIME = 2021 and s.TIME = 2021 and t.TIME = 2021;

select * from oecd_indexes;

select * from average_annual_labor;

create temporary table wiki_max_and_mins
select max(w.2020) as max_w, min(w.2020) as min_w
from unemployment_female as f
left join regions as r on f.economy = r.id
left join average_annual_labor as w on w.Code = r.id;

create temporary table wiki_indexes
select r.id as id, r.name as name, (m.max_w-w.2020)/(m.max_w-m.min_w) as wiki_index
from unemployment_female as f
left join regions as r on f.economy = r.id
left join average_annual_labor as w on w.Code = r.id
left join wiki_max_and_mins as m on true;

select * from wiki_indexes;

create temporary table composite_index
select a.id, a.name, if(a.id = "CYP" or a.id = "MLT", ((a.index_fem + a.index_tot + a.index_youth + w.wiki_index)/4),
((a.index_fem + a.index_tot + a.index_youth + w.wiki_index)/5)
+ (o.index_basics + o.index_secondary + o.index_tertiary)/15) as employability_composite_index
from wbapi_indexes as a
left join oecd_indexes as o on a.id = o.id
left join wiki_indexes as w on w.id = a.id;

select * from composite_index;


