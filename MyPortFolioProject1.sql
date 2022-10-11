select * 
from MyPortFolioProject..CovidDeath
order by 3, 4


select *  from MyPortFolioProject..CovidVaccination
order by 3,4



--select data that we are going to using

select location, date, total_cases, new_cases, total_deaths, population
from MyPortFolioProject..CovidDeath
order by 1, 2

--Looking at Total Cases vs total death
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
from MyPortFolioProject..CovidDeath
where location like '%state%'
order by 1, 2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid
select location, date,population, total_cases,  (total_cases/population) * 100 AS DeathPercentage
from MyPortFolioProject..CovidDeath
--where location like '%States%'
order by 1, 2


--Looking at countiries with highest infection rate compare to population
select location, population, MAX(total_cases) as HightestInfectionCount,  max((total_cases/population)) * 100 AS PercentageOfPopulationInfected
from MyPortFolioProject..CovidDeath
--where location like '%States%'
group by population, location
order by PercentageOfPopulationInfected DESC

-- Showing the Countries Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from MyPortFolioProject..CovidDeath
--where location like '%States%'
where continent is not null
group by location
order by TotalDeathCount DESC


--Let's Break Down by Continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from MyPortFolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount DESC


--GLOBAL numbers
--1 for tablue table1
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int)) /
sum(new_cases) * 100 as deathPercentage
from MyPortFolioProject..CovidDeath
where continent is not null 
--group by date
order by 1, 2

--lets look at covid vaccination table
select * from MyPortFolioProject..CovidVaccination

--2
select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from MyPortFolioProject..CovidDeath
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

--3
select location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected
from MyPortFolioProject..CovidDeath
group by location, population,date
order by PercentPopulationInfected desc

--4
select location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected
from MyPortFolioProject..CovidDeath
group by location, population,date
order by PercentPopulationInfected desc



--Looking at Total Population VS Total Vaccination

select *
from MyPortFolioProject..CovidVaccination

select de.continent, de.location, de.date, de.population, va.new_vaccinations
from MyPortFolioProject..CovidDeath de
join MyPortFolioProject..CovidVaccination va
on de.continent = va.continent
and de.date =va.date
where de.continent is not null
--group by de.continent
order by 2,3


select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(convert (int,va.new_vaccinations)) OVER (partition by de.location order by de.location, de.date)
from MyPortFolioProject..CovidDeath de
join MyPortFolioProject..CovidVaccination va
on de.continent = va.continent
and de.date = va.date
where de.continent is not null
order by 2,3

select de.continent, de.location, de.population, va.new_vaccinations 
, SUM(CAST(va.new_vaccinations as int)) OVER (Partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from MyPortFolioProject..CovidDeath de
join MyPortFolioProject..CovidVaccination va
on de.location = va.location
and de.date = va.date
where de.continent is not null
order by 2, 3

-- USE CTE

with PopvsVacc (continent, location, population, new_vaccination, RollingPeopleVaccinated)
as(
select de.continent,de.location, de.population, va.new_vaccinations
, SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from MyPortFolioProject..CovidDeath de
join MyPortFolioProject..CovidVaccination va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--order by 2, 3
)
select *,(RollingPeopleVaccinated/population) * 100
from PopvsVacc

--TEMP TABLE
DROP table IF exists #PersentPopulationVaccinated
CREATE TABLE #PersentPopulationVaccinated
(continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PersentPopulationVaccinated
select de.continent,de.location,de.date, de.population, va.new_vaccinations
, SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from MyPortFolioProject..CovidDeath de
join MyPortFolioProject..CovidVaccination va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--order by 2, 3
select *,(RollingPeopleVaccinated/population) * 100
from #PersentPopulationVaccinated


--Create View 

Create view PersentPopulationVaccinated as
select de.continent,de.location,de.date, de.population, va.new_vaccinations
, SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from MyPortFolioProject..CovidDeath de
join MyPortFolioProject..CovidVaccination va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--order by 2, 3

select * from PersentPopulationVaccinated