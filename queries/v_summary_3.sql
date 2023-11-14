CREATE VIEW summary_3 AS
SELECT
	klient,
	product_group,
	indeks,
	SUM(wartosc_sprzedazy_w_cenach_kat_z_logiki * discount_1) AS discount_1,
	SUM(wartosc_sprzedazy_w_cenach_kat_z_logiki * discount_2) AS discount_2,
	SUM(wartosc_sprzedazy_w_cenach_kat_z_logiki * discount_3) AS discount_3,
	SUM(wartosc_sprzedazy_w_cenach_kat_z_logiki * discount_4) AS discount_4,
	SUM(wartosc_sprzedazy_w_cenach_kat_z_logiki * discount_5) AS discount_5
FROM data_all
GROUP BY 1,2,3