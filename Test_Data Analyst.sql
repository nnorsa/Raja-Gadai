#ANALISIS GMS
#NO.1 (10 penjualan terbsesar Publisher berdasarkan Global sales)
SELECT Publisher,
	   ROUND(sum(Global), 2) as Penjualan
FROM gms
GROUP BY 1
ORDER BY sum(Global) DESC
LIMIT 10;

#No. 1.1 (publisher yang menempati juara ke 2 & 3, rekomendasi apa yang akan anda berikan untuk meningkatkan penjualan?)
(SELECT Publisher,
	   Platform,
	   Genre,
       ROUND(sum(Global), 2) as Penjualan
FROM gms
WHERE Publisher = 'Electronic Arts'
GROUP BY 1,2,3
LIMIT 5)
UNION ALL
(SELECT Publisher,
	   Platform,
	   Genre,
       ROUND(sum(Global), 2) as Penjualan
FROM gms
WHERE Publisher = 'Activision'
GROUP BY 1,2,3
LIMIT 5)
ORDER BY Publisher DESC, Penjualan DESC;

#Sub 1.2 (Platform dan genre apa yang anda sarankan untuk Sega publisher kembangkan?)
SELECT Platform,
	   Genre,
       ROUND(sum(Global), 2) as Global_Sales
FROM gms
WHERE Publisher = "Sega"
GROUP BY 1,2
ORDER BY Global_Sales DESC
LIMIT 10;

#No.2 (preferensi platform dan genre game dari setiap region)
SELECT Platform,
	   Genre,
       ROUND(sum(Amerika), 2) as Amerika_Sales
FROM gms
GROUP BY 1,2
ORDER BY Amerika_Sales DESC
LIMIT 5;

SELECT Platform,
	   Genre,
       ROUND(sum(Europe), 2) as Europe_Sales
FROM gms
GROUP BY 1,2
ORDER BY Europe_Sales DESC
LIMIT 5;

SELECT Platform,
	   Genre,
       ROUND(sum(Jepang), 2) as Jepang_Sales
FROM gms
GROUP BY 1,2
ORDER BY Jepang_Sales DESC
LIMIT 5;

#ANALISIS AMZ
#No.1 (informasi total penjualan per quarter disetiap negara)
SELECT Negara,
	   year(Invoice_Date) as Tahun,
	   quarter(Invoice_Date) as Quarter,
	   ROUND(sum(Qty*Price), 2) as Total_Penjualan
FROM amz
GROUP BY 1,2,3;

#Sub 1.2 (proyeksi semua penjualan per quarter di setiap negara untuk 1 tahun kedepan)
WITH Quarter_Sales AS (
	SELECT Negara,
		   year(Invoice_Date) as Tahun,
	       quarter(Invoice_Date) as Quarter,
	       ROUND(sum(Qty*Price), 2) as Total_Penjualan
	FROM amz
	GROUP BY 1,2,3
),
Average_QS AS (
	SELECT Negara,
		   Quarter,
           ROUND(avg(Total_Penjualan), 2) as Avg_Penjualan
	FROM Quarter_Sales
    GROUP BY 1,2
),
Max_Year AS (
	SELECT MAX(YEAR(Invoice_Date)) + 1 as Tahun
    FROM amz
)
SELECT Negara,
	   (SELECT Tahun FROM Max_Year) as Tahun,
       Quarter,
       Avg_Penjualan as Proyeksi_Sales
FROM Average_QS
GROUP BY 1,3
ORDER BY Quarter ASC, Proyeksi_Sales DESC;

#No.2 (informasi jumlah transaksi top 10 customer)
SELECT Cust_id,
	   count(Invoice) as Jumlah_Transaksi
FROM amz
#WHERE Invoice NOT LIKE 'A%' AND Invoice NOT LIKE 'C%'
GROUP BY 1
ORDER BY Jumlah_Transaksi DESC
LIMIT 10;

#Sub 2.1 (jumlah retur per customer)
SELECT Cust_id,
	   count(Invoice) as Jumlah_Retur
FROM amz
WHERE Invoice LIKE 'C%'
GROUP BY 1
ORDER BY Jumlah_Retur DESC;

#Sub 2.2 (Adakah kesamaan prefrensi produk antara customer?)
SELECT SKU,
       count(distinct Cust_id) as Jumlah_Cust
FROM amz
GROUP BY 1
HAVING Jumlah_Cust > 1
ORDER BY Jumlah_Cust DESC;

#Sub 2.3 (Buatkan segmentasi customer)
SELECT Cust_id,
	   SKU,
       sum(Qty) AS Total_Qty,
       ROUND(sum(Price * Qty), 2) AS Total_Pengeluaran_Cust,
       Negara
FROM amz
GROUP BY 1,2,5
ORDER BY Total_Pengeluaran_Cust DESC;
