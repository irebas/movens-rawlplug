CREATE VIEW summary_3 AS
SELECT
	klient,
	product_group,
	indeks,
	SUM(wartosc_sprzedazy_w_cenach_kat_elast * discount_1) AS discount_1,
	SUM(wartosc_sprzedazy_w_cenach_kat_elast * discount_2) AS discount_2,
	SUM(wartosc_sprzedazy_w_cenach_kat_elast * discount_3) AS discount_3,
	SUM(wartosc_sprzedazy_w_cenach_kat_elast * discount_4) AS discount_4,
	SUM(wartosc_sprzedazy_w_cenach_kat_elast * discount_5) AS discount_5,
	SUM(wartosc_sprzedazy_w_cenach_logika_elast) AS wartosc_sprzedazy_w_cenach_z_logiki_elast,
	SUM(wartosc_sprzedazy_w_cenach_kat_elast) AS wartosc_sprzedazy_w_cenach_kat_elast
FROM data_all
GROUP BY 1,2,3