-- Showing the retrived Data
Select *
From Census_2011.dbo.Data1

Select *
From Census_2011.dbo.Data2

-- Counting the number of rows in both datasets using count function
select COUNT(*)  as 'Number of rows'
from Census_2011..data1

select COUNT(*)  as 'Number of rows'
from Census_2011..data2

--Getting Dataset for Delhi and Bihar using Where and IN 
select * 
from Census_2011..Data1
where [State ] in ('delhi' , 'bihar')

--Getting total population of india using sum and renaming the column using as
select sum(Population) as 'Total Population'
from Census_2011..Data2

--Average Growth of India using avg function
select AVG(growth)*100 average_growth 
from Census_2011..Data1

--Average Growth Rate state wise
Select state, AVG(growth)*100 as avg_growth
from Census_2011..Data1
Group by state

--Average Sex Ratio state wise using round and group by function
Select state, round(AVG(Sex_Ratio),0) as avg_sex_ratio
from Census_2011..Data1
Group by state
order by avg_sex_ratio desc

--Average Litrecy Rate
Select state, round(AVG(Literacy),0) as avg_literacy
from Census_2011..Data1
Group by state
order by avg_literacy desc

--Extracting states with literacy rate higher than 90
Select state, round(AVG(Literacy),0) as avg_literacy
from Census_2011..Data1
Group by state
Having  round(AVG(Literacy),0)>90
order by avg_literacy 

--Top 3 states having highest growth rate
Select top 3 state, AVG(growth)*100 as avg_growth
from Census_2011..Data1
Group by state
order by avg_growth desc

--Top 3 states having highest literacy rate
Select top 3 state, round(AVG(Literacy),0) as avg_literacy
from Census_2011..Data1
Group by state
order by avg_literacy desc

--Top 3 states having highest sex_ratio
Select top 3 state, round(AVG(Sex_Ratio),0) as avg_sex_ratio
from Census_2011..Data1
Group by state
order by avg_sex_ratio desc

--bottom 3 states having lowest literacy
select  state,avg(literacy) literacy_rate
FROM Census_2011..Data1
group by state
order by literacy_rate desc

--Now we create a new table to show top  states together according to literacy rate
drop table if exists #topstates;
create table #topstates
(state nvarchar(255),
topstate float
)

insert into #topstates
Select state, round(AVG(Literacy),0) as avg_literacy
from Census_2011..Data1
Group by state
order by avg_literacy desc

select top 3 *
from #bottomstates
order by #bottomstates.bottomstate desc

--Now we create a new table to bottom states together according to literacy rate
drop table if exists #bottomstates;
create table #bottomstates
(state nvarchar(255),
bottomstate float
)

insert into #bottomstates
Select state, round(AVG(Literacy),0) as avg_literacy
from Census_2011..Data1
Group by state
order by avg_literacy desc

select top 3*
from #bottomstates
order by #bottomstates.bottomstate

--using the union operator to combine top and bottom states in one table
select * from
(select top 3*
from #bottomstates
order by #bottomstates.bottomstate) a

union 

select * from
(select top 3 *
from #bottomstates
order by #bottomstates.bottomstate desc) b

--states starting with letter a and unique names only
select distinct state
from Census_2011..Data1
where state like 'a%'
order by state

--states starting with letter a or b
select distinct state
from Census_2011..Data1
where state like 'a%' or state like 'b%'
order by state

--Joining both tables
select a.District,a.State,Sex_Ratio,Population
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District

--Calculating total numbers of males and females
select d.state,d.male_population,d.female_population from
(select c.state,c.district,round(c.population/(c.sex_ratio+1),0) male_population, round((c.population*c.sex_ratio)/(c.sex_ratio + 1),0) female_population
from (select a.District,a.State,a.Sex_Ratio/1000 sex_ratio,Population
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District) c) d

--grouping by states
select d.state,sum(d.male_population) total_males,sum(d.female_population) total_females from
(select c.state,c.district,round(c.population/(c.sex_ratio+1),0) male_population, round((c.population*c.sex_ratio)/(c.sex_ratio + 1),0) female_population
from (select a.District,a.State,a.Sex_Ratio/1000 sex_ratio,Population
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District) c) d
group by d.state

--number of literate and illiterate people
 select d.state,sum(d.literate_population) total_literate,sum(d.illiterate_population) total_illiterate from
(select c.state,c.district,round(c.literacy_ratio*c.population,0) literate_population, round((1-c.literacy_ratio)*c.population,0) illiterate_population
from (select a.District,a.State,a.Literacy/100 literacy_ratio,Population
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District) c) d
group by d.state

-- population in previous census state wise
select e.state,sum(e.previous_census_popultion) previous_census_popultion,sum(e.current_census_population) current_census_population from
(select d.district, d.state, round(d.population/(1+ d.growth_rate),0) previous_census_popultion, d.population current_census_population from
(select a.District,a.State,a.growth growth_rate,Population
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District) d) e
group by e.state 

--total population in previous census vs current census
select sum(f.previous_census_popultion) total_previous_census_population, sum(f.current_census_popultion)  total_current_census_population from
(select e.state,sum(e.previous_census_popultion) previous_census_popultion ,sum(e.current_census_population) current_census_popultion from
(select d.district, d.state, round(d.population/(1+ d.growth_rate),0) previous_census_popultion, d.population current_census_population from
(select a.District,a.State,a.growth growth_rate,Population
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District) d) e
group by e.state ) f

-- reduction in area per person from last census
select '1' as keyy,g.* from
(select sum(f.previous_census_popultion) total_previous_census_population, sum(f.current_census_popultion)  total_current_census_population from
(select e.state,sum(e.previous_census_popultion) previous_census_popultion ,sum(e.current_census_population) current_census_popultion from
(select d.district, d.state, round(d.population/(1+ d.growth_rate),0) previous_census_popultion, d.population current_census_population from
(select a.District,a.State,a.growth growth_rate,Population
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District) d) e
group by e.state ) f)g

select '1' as keyy,p.* from
(select sum(area_km2) total_area
from Census_2011..Data2) p

-- combining both tables with common key
select (g.total_area/g.previous_census_population) previous_census_population_vs_area,(g.total_area/g.current_census_population) current_census_population_vs_area from
(select q.*,r.total_area from(

select '1' as keyy,n.* from
(select sum(m.previous_census_popultion) previous_census_population, sum(m.current_census_popultion) current_census_population from
(select e.state,sum(e.previous_census_popultion) previous_census_popultion ,sum(e.current_census_population) current_census_popultion from
(select d.district, d.state, round(d.population/(1+ d.growth_rate),0) previous_census_popultion, d.population current_census_population from
(select a.District,a.State,a.growth growth_rate,b.Population 
from Census_2011..Data1 a
join Census_2011..Data2 b
on a.District = b.District) d) e
group by e.state) m) n) q
inner join 
(select '1' as keyy,z.* from
(select sum(area_km2) total_area
from Census_2011..Data2) z) r
on q.keyy=r.keyy)g

