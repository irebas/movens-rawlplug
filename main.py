from datetime import datetime

import pandas as pd

from sqlite import SQLite
from variables import DB_NAME, RESULTS_PATH, PARAMS_PATH, SHEETS


def insert_results():
    df = pd.read_csv(RESULTS_PATH)
    SQLite(DB_NAME).create_table(df=df, table_name='results')


def insert_params():
    for sh in SHEETS:
        df = pd.read_excel(PARAMS_PATH, sheet_name=sh)
        SQLite(DB_NAME).create_table(df=df, table_name=sh)


def get_summary():
    t0 = datetime.now()
    df = SQLite(DB_NAME).run_sql_query('queries/summary.sql')
    ts = datetime.now().date().strftime('%Y%m%d')
    df.to_csv(f'outputs/summary_{ts}.csv', encoding='utf-8')
    print(f'Data extracted: {datetime.now() - t0}')


def main():
    code = input('Select function code:\nR - update results\nP - update params\n'
                 'S - get summary to csv\nQ - quit\nCode: ')
    match code:
        case 'R': insert_results()
        case 'P': insert_params()
        case 'S': get_summary()
        case 'Q': quit()
        case _: print('Wrong code')
    main()
