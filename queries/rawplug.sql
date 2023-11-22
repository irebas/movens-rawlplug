--DROP VIEW data_all
--CREATE VIEW data_all AS
WITH t1 AS (
	SELECT
		r.faktura,
		r.indeks,
		r.klient,
		r.w_ilosc,
		r.w_PLN,
		r.w_katal,
		pl.kws_sa,
		r.w_PLN - pl.kws_sa AS masa_marzy_status_quo,
		r.w_PLN / w_ilosc AS cena_transakcyjna,
		CASE
			WHEN r.jedn IN ('op', 'bl') THEN r.w_ilosc
			WHEN r.jedn IN ('sz', 'kg') THEN ROUND(r.w_ilosc / pl.logic_sztuki_w_opakowaniu, 2)
			ELSE ROUND(1000 / pl.logic_sztuki_w_opakowaniu * r.w_ilosc, 2)
		END AS liczba_opakowan,
		pl.product_group,
		pl.unit * pl.price AS logic_price_js,
		(SELECT value FROM params1 WHERE df_code = '0A') AS param_0a,
		(SELECT value FROM params1 WHERE df_code = '3A') AS param_3a,
		(SELECT value FROM params1 WHERE df_code = '4A') AS param_4a,
		(SELECT value FROM params1 WHERE df_code = '4B') AS param_4b,
		(SELECT value FROM params1 WHERE df_code = '4C') AS param_4c,
		(SELECT value FROM params1 WHERE df_code = '6A') AS param_6a,
		(SELECT value FROM params1 WHERE df_code = '6B') AS param_6b,
		(SELECT value FROM params1 WHERE df_code = '6C') AS param_6c,
		p.segment
	FROM results r LEFT JOIN prices_logic pl ON r.indeks = pl.indeks
	LEFT JOIN products p ON r.indeks = p.indeks
	WHERE r.korekta_do IS NULL AND r.indeks IN (SELECT indeks FROM prices_logic) AND r.klient IN (SELECT klient FROM clients)
),

t2 AS (
	SELECT
		t1.*,
		t1.logic_price_js * (1 + t1.param_0a) AS logic_catalog_price,
		CASE
			WHEN t1.liczba_opakowan <= v2.small_volume THEN 'Small volume'
			WHEN t1.liczba_opakowan > v2.big_volume THEN 'Big volume'
			ELSE 'Medium volume'
		END AS volume_level
	FROM t1 LEFT JOIN volume2 v2 ON t1.product_group = v2.product_group
),

t3 AS (
	SELECT
		t2.*,
		v3.discount_1,
		p2.discount_2,
		IIF(s.segment IS NULL, 0, t2.param_3a) AS discount_3,
		c.client_sr_termin * t2.param_4b / 30 * param_4a * param_4c AS discount_4,
		param_6c AS discount_5,
		COALESCE(v3.discount_1, 0) + COALESCE(p2.discount_2, 0) + IIF(s.segment IS NULL, 0, t2.param_3a) + COALESCE((c.client_sr_termin * t2.param_4b / 30 * param_4a * param_4c), 0) + COALESCE(param_6c, 0) AS total_discount
	FROM t2 LEFT JOIN clients c ON t2.klient = c.klient
	LEFT JOIN params2 p2 ON c.client_segment_1 = p2.client_segment_1 AND c.client_segment_2 = p2.client_segment_2
	LEFT JOIN volume3 v3 ON t2.volume_level = v3.volume_level
	LEFT JOIN clients_segments s ON t2.klient = s.klient AND t2.segment = s.segment
),

t4 AS (
	SELECT
		*,
		logic_catalog_price * w_ilosc AS wartosc_sprzedazy_w_cenach_kat_z_logiki,
		(1 - total_discount) * logic_catalog_price AS cena_z_logiki_klient,
		(1 - total_discount) * logic_catalog_price * w_ilosc AS wartosc_sprzedazy_w_cenach_z_logiki,
		((1 - total_discount) * logic_catalog_price * w_ilosc) - kws_sa AS masa_marzy_w_cenach_z_logiki,
		((1 - total_discount) * logic_catalog_price) / cena_transakcyjna - 1 AS cena_z_logiki_vs_transakcyjna
	FROM t3
),

t5 AS (
	SELECT
		t4.*,
		CASE
			WHEN cena_z_logiki_vs_transakcyjna > 0 THEN e.elast_increase
			ELSE e.elast_decrease
		END AS elast_cenowa
	FROM t4 LEFT JOIN elasticity e ON t4.product_group = e.product_group
),

t6 AS (
	SELECT
		*,
		IIF((cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc > 0, (cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc, 0) AS elast_volume,
		IIF((cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc > 0, (cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc, 0) * logic_catalog_price AS wartosc_sprzedazy_w_cenach_kat_elast,
		IIF((cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc > 0, (cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc, 0) * cena_z_logiki_klient AS wartosc_sprzedazy_w_cenach_logika_elast,
		(cena_z_logiki_klient - kws_sa / w_ilosc) * IIF((cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc > 0, (cena_z_logiki_vs_transakcyjna * elast_cenowa + 1) * w_ilosc, 0) AS masa_marzy_elast
	FROM t5
),

t7 AS (
	SELECT
	    faktura, indeks, klient, w_ilosc, w_PLN, w_katal, kws_sa, product_group, masa_marzy_status_quo, cena_transakcyjna,
	    liczba_opakowan, volume_level, discount_1, discount_2, discount_3, discount_4, discount_5, total_discount,
	    logic_catalog_price, logic_price_js, wartosc_sprzedazy_w_cenach_kat_z_logiki, cena_z_logiki_klient, wartosc_sprzedazy_w_cenach_z_logiki,
	    masa_marzy_w_cenach_z_logiki, cena_z_logiki_vs_transakcyjna, elast_cenowa, elast_volume, wartosc_sprzedazy_w_cenach_kat_elast,
	    wartosc_sprzedazy_w_cenach_logika_elast, masa_marzy_elast
	FROM t6
)

SELECT * FROM t7