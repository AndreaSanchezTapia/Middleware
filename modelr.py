#!/usr/bin/env python
# -*- coding: utf-8 -*-

import csv
import requests

def get_experiments_by_status(status=2):
    url = 'http://model-r.jbrj.gov.br/ws/'
    payload = {'status': status}
    r = requests.get(url, params=payload)
    return r.json()

def update_experiment_status(id_experiment, status):
    url = 'https://model-r.jbrj.gov.br/ws/setstatus.php'
    payload = {'id': id_experiment, 'status': status}
    r = requests.get(url, params=payload)
    update_status = r.json()
    return update_status['experiment'][0]

def get_occurrences_by_status(experiment, status):
    all_points = experiment['occurrences']
    return [point for point in all_points if point['idstatusoccurrence'] == status]

def write_occurrences_csv(list_of_points, output_file):
    with open(output_file, 'w') as csvfile:
        fieldnames = ['taxon', 'lon', 'lat']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, extrasaction='ignore')
        writer.writeheader()
        for point in list_of_points:
            writer.writerow(point)

# TODO raise Exception when a web service error occurs.
def inform_experiment_results(evaluate_info):
    url = 'https://model-r.jbrj.gov.br/ws/setresult.php'
    r = requests.post(url, data=evaluate_info)
    return r.json()
