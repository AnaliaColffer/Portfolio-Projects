/* CLEANING REAL ESTATE DATA IN SQL

	Project by: Analia Colffer 

The project below is divided in 5 parts: 

	1. Standardize date column format, 
	2. Populate null property addresses,
	3. Split property and owner addresses into street address, city, and state, 
	4. Standardize sold as vacant column, and
	5. Remove duplicates
*/

-------------------------------------------------------------------------------------------------------

/* PART 1: STANDARDIZE DATE FORMAT
Current format is YYYY-MM-DD HH:MM:SS, I will transform the data so that it's only YYYY-MM-DD
*/

ALTER TABLE NashvilleHousing
	ADD SaleDateConverted Date;

Update NashvilleHousing
	SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Check if the conversion was successfully done
SELECT SaleDateConverted FROM NashvilleHousing;


-------------------------------------------------------------------------------------------------------

/* PART 2: POPULATE NULL PROPERTY ADDRESS VALUES 
Some rows have the same parcel ID, owner, legal reference, but no property address. 
-- There are 29 nulls in Property Address
-- I will write a query that populates null addresses based on Parcel ID
*/

SELECT 
	A.ParcelID
	,A.PropertyAddress
	,B.ParcelID
	,B.PropertyAddress
	,ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]


-------------------------------------------------------------------------------------------------------

/* PART 3: BREAK APART ADDRESS 
Split Property Address column into two separate columns: Property Address and Property City
*/

SELECT
	SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)							AS Address
	,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))		AS Address
FROM PortfolioProject.DBO.NashvilleHousing


ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)
;

ALTER TABLE NashvilleHousing
	ADD PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- Split Owner address into three separate columns, owner address, owner city, and owner state
-- Write query

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)		
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

FROM PortfolioProject.DBO.NashvilleHousing


-- Alter and Update tables to reflect change

ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3);

ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2);

ALTER TABLE NashvilleHousing
	ADD OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1);


-------------------------------------------------------------------------------------------------------

/* PART 4: STANDARDIZE SOLD AS VACANT
	As of now, the column has "Yes", "Y", "No", and "N" as possible values.
	I will change it to Y and N
*/

SELECT
	DISTINCT(SoldAsVacant)
	,COUNT(*)
FROM PortfolioProject.DBO.NashvilleHousing
group by SoldAsVacant
order by 2

SELECT
	SoldAsVacant
	,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.DBO.NashvilleHousing

Update NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END

-------------------------------------------------------------------------------------------------------
/* PART 5: Remove row duplicates
*/


WITH RowNumCTE AS
(
SELECT 
	*
	,ROW_NUMBER() OVER(PARTITION BY 
						PARCELID
						,PROPERTYADDRESS
						,SALEPRICE
						,SALEDATE
						,LEGALREFERENCE
						ORDER BY UNIQUEID
						) AS ROW_NUM

FROM PortfolioProject.DBO.NashvilleHousing
)
-- Identify number of duplicates
-- We have 104 duplicates
SELECT * FROM RowNumCTE
Where ROW_NUM > 1
Order by PropertyAddress

-- Delete duplicates

WITH RowNumCTE AS
(
SELECT 
	*
	,ROW_NUMBER() OVER(PARTITION BY 
						PARCELID
						,PROPERTYADDRESS
						,SALEPRICE
						,SALEDATE
						,LEGALREFERENCE
						ORDER BY UNIQUEID
						) AS ROW_NUM

FROM PortfolioProject.DBO.NashvilleHousing
)

DELETE
FROM RowNumCTE
Where ROW_NUM > 1
;
