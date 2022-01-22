select * from Covid_Deaths

--85171


	select location,date, total_cases, new_cases, total_deaths, population
	from Covid_Deaths
	order by 1,2

--total cases V/S total deaths
--SHOWS LIKELIHOOD of dying if you contract covid in your country
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Covid_Deaths
WHERE location LIKE '%STATES%'
and continent is not null
order by 1,2

--ALTER TABLE Covid_Deaths
--ALTER COLUMN total_deaths FLOAT

ALTER TABLE Covid_Deaths
ALTER COLUMN total_cases int


ALTER TABLE Covid_Vaccinations
ALTER COLUMN new_vaccinations int

--loking at total cases vs population
--WHAT % HAS GOT COVID
select location,date,population, total_cases, (total_cases/population)*100 as Deathpercentage 
from Covid_Deaths
--WHERE location LIKE '%INDIA%'
order by 1,2


--LOOKING COUNTRY WITH HIGHEST INFECTION RATE COMPARTED TO POULATION

select location,population, MAX(total_cases) AS HighInfectcount, Max(total_cases/population)*100 as Percentgotinfected 
from Covid_Deaths
--WHERE location LIKE '%INDIA%'
group by location,population
order by Percentgotinfected desc

--country showing highest death count per population

select location, MAX(total_deaths) AS Totaldeath
from Covid_Deaths
--WHERE location LIKE '%INDIA%'
where continent is not null
group by location
order by Totaldeath	 desc

--Break things down by continent
--country showing highest death count per population

select continent, MAX(CAST(total_deaths AS int)) AS TotaldeathScOUNT
from Covid_Deaths
--WHERE location LIKE '%INDIA%'
where continent is not null
group by continent
order by TotaldeathScOUNT	 desc

--GLOBAL NUMBERS
Select sum(cast(new_cases as int)) as total_cases,sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/
sum(cast(new_cases as int))*100 as Deathpercentage
from Covid_Deaths
--where location like '%ind%'
where continent is not null
--group by date
order by 1,2


---Looking at total population VS vaccination


With PopvsVac(continent,Location,Date,Population,new_vaccinations,RollingpeopleVaccination)
as
(select d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location ) AS RollingpeopleVaccination
from Covid_Deaths d join Covid_Vaccinations V
on V.LOCATION=D.LOCATION AND
D.DATE = V.Date
where d.continent is not null
--group by date
--order by 2,3
)

select * ,(RollingpeopleVaccination/population)*100 
from PopvsVac
--USING CTE

--TEMP TABLE

DROP TABLE IF exists #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccination numeric
)
Insert into #PERCENTPOPULATIONVACCINATED
select d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location ) AS RollingpeopleVaccination
from Covid_Deaths d join Covid_Vaccinations V
on V.LOCATION=D.LOCATION AND
D.DATE = V.Date
--where d.continent is not null
--group by date
--order by 2,3

select * ,(RollingpeopleVaccination/population)*100 
from #PERCENTPOPULATIONVACCINATED


--Creating Views to storedata for later visualisation

create view PERCENTPOPULATIONVACCINATED as
select d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location ) AS RollingpeopleVaccination
from Covid_Deaths d join Covid_Vaccinations V
on V.LOCATION=D.LOCATION AND
D.DATE = V.Date
where d.continent is not null