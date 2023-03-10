
-- Data Cleaning in SQL, Nashville Housing Project

CREATE DATABASE NashvilleHousingProject;

SELECT * 
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning];

-- Populate Property Address data
SELECT PropertyAddress 
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
WHERE PropertyAddress is null;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning] AS a
JOIN NashvilleHousingProject..[Nashville Housing Data for Data Cleaning] AS b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning] AS a
JOIN NashvilleHousingProject..[Nashville Housing Data for Data Cleaning] AS b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

-- Separting PropertyAddress into Individual Columns (Street, City)
-- Using the sunstring method(Advanced)

SELECT PropertyAddress 
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address, -- creating substrings for spilting the address into address and city
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]

ALTER TABLE NashvilleHousingProject..[Nashville Housing Data for Data Cleaning] -- creating a new column by altering the table
Add PropertyAddressSlipt Nvarchar(255);
Update NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
SET PropertyAddressSlipt = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
Add PropertyCity Nvarchar(255);
Update NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

SELECT * 
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]

-- Separting OwnerAddress into Individual Columns (Street, City, State)
-- Using the parsename method

SELECT OwnerAddress 
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning];

ALTER TABLE NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
Add OwnerStreet Nvarchar(255);
Update NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
Add OwnerCity Nvarchar(255);
Update NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
Add OwnerState Nvarchar(255);
Update NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * 
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning];

-- Alter the Y and N rows to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant) -- checking the count of unique inputs
FROM NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2;

Update NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	                    When SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END;
GO

-- To remove duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousingProject..[Nashville Housing Data for Data Cleaning])

DELETE
From RowNumCTE
Where row_num > 1;

-- Deleting unwanted columns already duplicated
ALTER TABLE NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
DROP COLUMN PropertyAddress, OwnerAddress; 

Select * -- final checks
From NashvilleHousingProject..[Nashville Housing Data for Data Cleaning]
 
-- END