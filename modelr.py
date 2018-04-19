#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib.request, urllib.parse, urllib.error
import urllib.request, urllib.error, urllib.parse
import json
import csv

def get_experiments_by_status(status=2):
    url = 'http://model-r.jbrj.gov.br/ws/?status=' + str(status)
    response = urllib.request.urlopen(url)
    all_exp_list = json.loads(response.read().decode('utf-8'))
    return all_exp_list

def update_experiment_status(id_experiment, status):
    url = 'https://model-r.jbrj.gov.br/ws/setstatus.php?id=%s&status=%d' %(id_experiment, int(status))
    response = urllib.request.urlopen(url)
    update_status = json.loads(response.read().decode('utf-8'))
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
# Right now it only prints the response for debugging purposes.
def inform_experiment_results(params):
    query = urllib.parse.urlencode(params).encode('utf-8')
    url = 'https://model-r.jbrj.gov.br/ws/setresult.php'
    f = urllib.request.urlopen(url, query)
    contents = f.read()
    print(contents)
    f.close()

def inform_partitions(exp_id, partition, algorithm, kappa, spec_sens,
        no_omission, prevalence, equal_sens_spec, sensitivity, auc, tss,
        raster_cut_path, png_bin_path, png_cont_path, png_cut_path):
    POST_params = {'id': exp_id,
            'idresulttype': '1',
            'op': 'I',
            'partition': partition,
            'algorithm': algorithm,
            'kappa': kappa,
            'spec_sens': spec_sens,
            'no_omission': no_omission,
            'prevalence': prevalence,
            'equal_sens_spec': equal_sens_spec,
            'sensitivity': sensitivity,
            'auc': auc,
            'tss': tss,
            'raster_cut_path': raster_cut_path,
            'png_bin_path': png_bin_path,
            'png_cont_path': png_cont_path,
            'png_cut_path': png_cut_path
            }
    inform_experiment_results(POST_params)

def inform_final_models(exp_id, raster_cut_path, png_cont_path, png_cut_path):
    POST_params = {'id': exp_id,
            'op': 'I',
            'idresulttype': '2',
            'raster_cut_path': raster_cut_path,
            'png_cont_path': png_cont_path,
            'png_cut_path': png_cut_path
            }
    inform_experiment_results(POST_params)

def inform_ensembles(exp_id, raster_cut_path, png_cont_path, png_cut_path):
    POST_params = {'id': exp_id,
            'op': 'I',
            'idresulttype': '3',
            'raster_cut_path': raster_cut_path,
            'png_cont_path': png_cont_path,
            'png_cut_path': png_cut_path
            }
    inform_experiment_results(POST_params)
