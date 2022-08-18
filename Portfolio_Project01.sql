select *
from porfolio_project.covid_deaths
order by 3,4; 

-- selecting data for use

select 
	location,
    date,
    total_cases,
    new_cases, 
    total_cases,
    total_deaths,
    population
from porfolio_project.covid_deaths; 

-- total cases vs total deaths 
-- likelihood of death upon contraction of covid

select 
	location,
    date,
    total_cases,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as death_percentage 
from porfolio_project.covid_deaths
where location like '%states%'; 

-- total cases vs population 
-- percentage of population that has contracted covid 

select 
	location,
    date,
    total_cases,
    population,
    (total_cases/population)*100 as infection_percentage 
from porfolio_project.covid_deaths
where location like '%states%'; 

-- countires with highest infection rate / population 

select 
	location,
    population,
    max(total_cases) as highest_infection_count,
    max((total_cases/population))*100 as infection_percentage 
from porfolio_project.covid_deaths
group by location, population
order by infection_percentage desc; 

-- countries with highest death count / population

select 
	location,
    max(cast(total_deaths as unsigned)) as total_death_count
from porfolio_project.covid_deaths
where continent is not null
group by location
order by total_death_count desc;

-- break down by continent 

select 
	continent,
    max(cast(total_deaths as unsigned)) as total_death_count
from porfolio_project.covid_deaths
where continent is not null 
group by continent 
order by total_death_count desc;

-- continents with the highest death count per population 

select 
	continent, 
    max(cast(total_deaths as unsigned)) as total_death_count
from porfolio_project.covid_deaths
where continent is not null 
group by continent
order by total_death_count desc; 

-- global break down of numbers 

select 
	date,
    sum(new_cases) as total_cases,
    sum(cast(new_deaths as unsigned)) as total_deaths,
    sum(cast(new_deaths as unsigned))/sum(new_cases) * 100 as death_percentage 
from porfolio_project.covid_deaths
where continent is not null 
group by date 
order by 1,2; 
    
-- total pop vs vaccinations 
-- cte for partition

with PopulationvsVaccination (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated) 
as 
(
select 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vacc.new_vaccinations,
    sum(cast(vacc.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) as rolling_populaiton_vaccinated
from porfolio_project.covid_deaths as dea
	join porfolio_project.covid_vaccinations as vacc
		on dea.location = vacc.location
        and dea.date = vacc.date
where dea.continent is not null; 
) 
Select *, (RollingPeopleVaccinated/Population)*100
From PoulationvsVaccination; 

-- using temp table 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From porfolio_project.covid_deaths dea
Join porfolio_project.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

-- creating views for viz

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From porfolio_project.covid_deaths as  dea
Join porfolio_project.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

