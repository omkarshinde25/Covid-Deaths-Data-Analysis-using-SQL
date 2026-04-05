

use [Alex.Portfolio_Project_1]
select count(*) from CovidVaccines

-- SELECT EVERITHING

select * from [dbo].[CovidDeaths] order by 3, 4
select * from CovidVaccines

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths] order by 1, 2

-- Looking at Total cases vs Total Deaths and the mortality rate 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Mortality_Rate_in_percent
from [dbo].[CovidDeaths] order by 1, 2

-- Looking at highest mortality rate 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Mortality_Rate_in_percent
from [dbo].[CovidDeaths] order by 5 DESC

-- Looking at United states mortality rate 
-- Shows likelihood of dying if you are in contact with covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Mortality_Rate_in_percent
from [dbo].[CovidDeaths] 
where location like '%states%'
order by 1, 2 

-- looking at Total cases vs Population
-- Shows what percentage of population got covid 

select location, date, total_cases, population, (total_cases/population)*100 as Percent_of_population
from [dbo].[CovidDeaths] 
where location like '%states%'
order by 1, 2 


-- Looking at countries with highest In fection Rate compared to Population
select location, population, Max(total_cases) as max_total_cases, Max((total_cases/population)*100) as Case_Per_Population_Rate_in_percent
from [dbo].[CovidDeaths] 
Group by location, population
order by 1, 2 

-- Looking at countries with highest In fection Rate compared to Population
select location, population, Max(total_cases) as max_total_cases, Max((total_cases/population)*100) as Case_Per_Population_Rate_in_percent
from [dbo].[CovidDeaths] 
Group by location, population
order by Case_Per_Population_Rate_in_percent Desc

--Showing countries with highest Death Count per population
select location, Max(cast(total_deaths as int)) as max_total_deaths
from [dbo].[CovidDeaths] 
where continent is not null
Group by location
order by max_total_deaths Desc

-- Lets Break Things Down By Continent
select continent, Max(cast(total_deaths as int)) as max_total_deaths
from [dbo].[CovidDeaths] 
where continent is not null
Group by continent
order by max_total_deaths Desc

-- Lets Break Things Down By location
select location, Max(cast(total_deaths as int)) as max_total_deaths
from [dbo].[CovidDeaths] 
where continent is null
Group by location
order by max_total_deaths Desc

-- Showing continents with the highest death count per population

select continent, Max(cast(total_deaths as int)) as max_total_deaths
from [dbo].[CovidDeaths] 
where continent is not null
Group by continent
order by max_total_deaths Desc

-- GLOBAL NUMBERS

select date, SUM(new_cases) total_cases_around_the_world, SUM(cast(new_deaths as int)) total_deaths_around_the_world,
			SUM(cast(new_deaths as int))/SUM(new_cases)*100 Death_rate
from [dbo].[CovidDeaths] 
where continent is not null
GROUP BY date
order by 1, 2


select SUM(new_cases) total_cases_around_the_world, SUM(cast(new_deaths as int)) total_deaths_around_the_world,
			SUM(cast(new_deaths as int))/SUM(new_cases)*100 Death_rate
from [dbo].[CovidDeaths] 
where continent is not null
order by 1, 2

-- vaccines

select * from CovidVaccines

-- Joining Two Tables (CovidDeaths and CovidVaccines) using JOIN

select * 
from CovidDeaths d Join CovidVaccines v 
On d.location = v.location 
and d.date = v.date

-- Looking at Total Population vs Vaccination using Partition

select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(bigint, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) rolling_counts_of_vaccination
from CovidDeaths d Join CovidVaccines v 
On d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2, 3
 

 -- Looking at Total Population vs Vaccination using Group By

select d.location, SUM(Convert(bigint, v.new_vaccinations)) as new_vaccination 
from CovidDeaths d Join CovidVaccines v 
On d.location = v.location 
and d.date = v.date
where d.continent is not null
Group by d.location
order by location

-- Using CTE

With Population_vs_Vaccination (Continent, Location, Date, Population, New_Vaccinations, rolling_counts_of_vaccination)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(bigint, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) rolling_counts_of_vaccination
from CovidDeaths d Join CovidVaccines v 
On d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2, 3
)
Select *, (rolling_counts_of_vaccination/Population)*100
From Population_vs_Vaccination 


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
rolling_counts_of_vaccination numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(bigint, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) rolling_counts_of_vaccination
from CovidDeaths d Join CovidVaccines v 
On d.location = v.location 
and d.date = v.date
where d.continent is not null

select *, (rolling_counts_of_vaccination/Population)*100 From #PercentPopulationVaccinated

-- Creating View to store data for later visualisation

Create View PercentPopulationVaccinatedView as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(bigint, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) rolling_counts_of_vaccination
from CovidDeaths d Join CovidVaccines v 
On d.location = v.location 
and d.date = v.date
where d.continent is not null