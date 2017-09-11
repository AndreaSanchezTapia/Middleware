#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import json
import csv

def get_experiments_by_status(status=2):
    url = 'http://model-r.jbrj.gov.br/ws/?status=' + str(status)
    response = urllib2.urlopen(url)
    all_exp_dict = json.loads(response.read())
    all_exp_list = all_exp_dict['experiment']
    return all_exp_list

def update_experiment_status(id_experiment, status):
    url = 'https://model-r.jbrj.gov.br/ws/setstatus.php?id=%s&status=%d' %(id_experiment, int(status))
    response = urllib2.urlopen(url)
    update_status = json.loads(response.read())
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
