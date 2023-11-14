CREATE VIEW summary AS
SELECT
	product_group,
	SUM(w_PLN) AS wartosc_sprzedazy_status_quo,
	SUM(masa_marzy_status_quo) AS masa_marzy_status_quo,
	SUM(wartosc_sprzedazy_w_cenach_kat_z_logiki) AS wartosc_sprzedazy_w_cenach_kat_z_logiki,
	SUM(wartosc_sprzedazy_w_cenach_z_logiki) AS wartosc_sprzedazy_w_cenach_z_logiki,
	SUM(masa_marzy_w_cenach_z_logiki) AS masa_marzy_w_cenach_z_logiki,
	SUM(wartosc_sprzedazy_w_cenach_z_logiki) / SUM(w_PLN) - 1 AS zmiana_wartosc_sprzedazy_vs_status_quo,
	SUM(masa_marzy_w_cenach_z_logiki) / SUM(masa_marzy_status_quo) - 1 AS zmiana_masy_marzy_vs_status_quo,
	SUM(wartosc_sprzedazy_w_cenach_kat_elast) AS wartosc_sprzedazy_w_cenach_kat_elast,
	SUM(wartosc_sprzedazy_w_cenach_logika_elast) AS wartosc_sprzedazy_w_cenach_logika_elast,
	SUM(masa_marzy_elast) AS masa_marzy_elast,
	SUM(wartosc_sprzedazy_w_cenach_logika_elast) / SUM(w_PLN) - 1 AS zmiana_wartosc_sprzedazy_vs_status_quo_2,
	SUM(masa_marzy_elast) / SUM(masa_marzy_status_quo) - 1 AS zmiana_masy_marzy_vs_status_quo_2,
	SUM(wartosc_sprzedazy_w_cenach_z_logiki) / SUM(wartosc_sprzedazy_w_cenach_kat_z_logiki) - 1 AS sredni_poziom_rabatowania
FROM data_all
WHERE product_group IS NOT NULL AND cena_transakcyjna NOT IN (0.01, 1)
GROUP BY 1