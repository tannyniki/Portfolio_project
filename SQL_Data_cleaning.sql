select * from Portfolio_Project.nashville_housing;



-- 1. Populate Property Address data
select *
from Portfolio_Project.nashville_housing
Where PropertyAddress = '';


Update Portfolio_Project.nashville_housing
set PropertyAddress = NULL
where PropertyAddress = '';


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.nashville_housing AS a
Join Portfolio_Project.nashville_housing AS b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL;


UPDATE Portfolio_Project.nashville_housing AS a
JOIN Portfolio_Project.nashville_housing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;





-- 2. Breaking out PropertyAddress into Individual Columns (Address, City)
select PropertyAddress
from Portfolio_Project.nashville_housing;

SELECT 
    SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS AddressPart1,
    SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 2) AS AddressPart2
FROM Portfolio_Project.nashville_housing;


ALter Table nashville_housing
ADD PropertyStreetAddress varchar(255);

Update nashville_housing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);


ALter Table nashville_housing
ADD PropertyCityAddress varchar(255);

Update nashville_housing
set PropertyCityAddress = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 2);



-- 3. Breaking out OwnerAddress into Individual Columns (Address, City, State)
SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS AddressPart1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS AddressPart2,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS AddressPart3
FROM Portfolio_Project.nashville_housing;


ALter Table nashville_housing
ADD OwnerStreetAddress varchar(255);

Update nashville_housing
SET OwnerStreetAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);


ALter Table nashville_housing
ADD OwnerCityAddress varchar(255);

Update nashville_housing
SET OwnerCityAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);


ALter Table nashville_housing
ADD OwnerStateAddress varchar(255);

Update nashville_housing
SET OwnerStateAddress = SUBSTRING_INDEX(OwnerAddress, ',', -1);


Select OwnerStreetAddress, OwnerCityAddress, OwnerStateAddress
From Portfolio_Project.nashville_housing;



-- 4. Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio_Project.nashville_housing
group by SoldAsVacant;



Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
        END as new
from Portfolio_Project.nashville_housing;


Update nashville_housing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
        END;



-- 5. Remove duplicates
CREATE TEMPORARY TABLE TempTable AS
SELECT UniqueID
FROM Portfolio_Project.nashville_housing
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) IN (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    FROM Portfolio_Project.nashville_housing
    GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    HAVING COUNT(*) > 1
);

DELETE FROM Portfolio_Project.nashville_housing
WHERE UniqueID IN (SELECT UniqueID FROM TempTable);

DROP TEMPORARY TABLE TempTable;




-- 6. Delete Unused Columns
Select * from Portfolio_Project.nashville_housing;


ALter table Portfolio_Project.nashville_housing
DROP OwnerAddress;

ALter table Portfolio_Project.nashville_housing
DROP PropertyAddress;

ALter table Portfolio_Project.nashville_housing
DROP TaxDistrict;












