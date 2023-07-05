--Cleaning data in SQL queries
select *
from Nashville

--Standardize date format
select SaleDateconverted,convert(date,saledate)
from Nashville

update Nashville
set SaleDate = CONVERT(date,saledate)

alter table nashville
add SaleDateConverted date;

update Nashville
set SaleDateConverted = CONVERT(date,saledate)


--Populate property adress
select *
from Nashville
--where PropertyAddress is null
order by ParcelID

--Hago un join con la misma tabla y veo cuales tienen el mismo parcelID teniendo distinto pk, o sea identifico que son distintas personas
--Encuentro la direccion de los que si tienen y ahora la copio y la pego en donde dice NULL
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from Nashville a 
join Nashville b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
	--where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)	
from Nashville a 
join Nashville b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, city, state)
select PropertyAddress
from Nashville
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as city
from Nashville



alter table nashville
add PropertySplitAddress Nvarchar(255)

update Nashville
set PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table nashville
add PropertySplitCity1 nvarchar(255)

update Nashville
set PropertySplitCity1 = SUBSTRING(propertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * from Nashville

--Owner address
select *
from Nashville

--Separando de nuevo pero ahora de una forma mucho mas sencilla
select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from Nashville

alter table nashville
add OwnerSplitAddress Nvarchar(255)

update Nashville
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table nashville
add OwnerSplitCity nvarchar(255)

update Nashville
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table nashville
add OwnerSplitState Nvarchar(255)

update Nashville
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in "SoldAsVacant" field
select distinct(soldasvacant), count(SoldasVacant)
from Nashville
group by SoldAsVacant
order by 2
--We have 'Y','N','Yes','No'

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	end
from Nashville

update Nashville
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes' when SoldAsVacant = 'N' then 'No' ELSE SoldAsVacant end


--Remove Duplicates
with RowNumCTE as(
Select *,
ROW_NUMBER() over(partition by parcelid, propertyaddress, saleprice, saledate, Legalreference order by uniqueID) row_num
from Nashville
--order by ParcelID
)
delete
from RowNumCTE
where row_num>1
--order by PropertyAddress


--Delete unused columns, generally be sure before doing this
	select * 
	from Nashville

alter table Nashville
drop column owneraddress, taxdistrict, propertyaddress

alter table Nashville
drop column saledate