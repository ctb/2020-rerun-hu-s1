# First-stage pipeline for Brown et al., 2018,
# https://www.biorxiv.org/content/early/2018/11/05/462788.
#
# See
#
#   https://github.com/dib-lab/2018-paper-spacegraphcats
#
# for source github repo.
#
# Contact: Titus Brown, ctbrown@ucdavis.edu.

import os
import itertools
import json, yaml
import screed

from spacegraphcats.snakemake import (catlas_build, catlas_search,
                                      catlas_extract_reads, catlas_search_input)


podar_ref_genomes = expand("podar-ref/{num}.fa", num=range(0, 64))

hu_bin_genomes = ["hu-genomes/hu-genome24.fa",
                  "hu-genomes/hu-genome33.fa", "hu-genomes/hu-genome25.fa",
                  "hu-genomes/hu-genome27.fa",
                  "hu-genomes/hu-genome40.fa", "hu-genomes/hu-genome30.fa",
                  "hu-genomes/hu-genome31.fa", "hu-genomes/hu-genome41.fa",
                  "hu-genomes/hu-genome26.fa", "hu-genomes/hu-genome35.fa",
                  "hu-genomes/hu-genome22.fa", "hu-genomes/hu-genome23.fa",
                  "hu-genomes/hu-genome34.fa", "hu-genomes/hu-genome36.fa",
                  "hu-genomes/hu-genome19.fa", "hu-genomes/hu-genome21.fa",
                  "hu-genomes/hu-genome20.fa", "hu-genomes/hu-genome37.fa",
                  "hu-genomes/hu-genome29.fa",
                  "hu-genomes/hu-genome28.fa", "hu-genomes/hu-genome32.fa",
                  "hu-genomes/hu-genome38.fa", "hu-genomes/hu-genome39.fa"]

strain_bacteroides = [x.strip() for x in open('conf/strain-bacteroides.txt')]
strain_gingivalis = [x.strip() for x in open('conf/strain-gingivalis.txt')]
strain_denticola = [x.strip() for x in open('conf/strain-denticola.txt')]

recover_ruminis = [x.strip() for x in open('conf/recover-ruminis.txt')]
recover_fuso = [x.strip() for x in open('conf/recover-fuso.txt')]

def signatures(*filenames):
    return [ x + '.sig' for x in itertools.chain(*filenames) ]


def add_suffix_to_search_output(conf_file, suffix):
    "Produce the list of contigs.sig files output by 'conf/run <config> search"
    with open(conf_file, 'rt') as fp:
        jj = yaml.safe_load(fp)

    catlas_base = jj['catlas_base']
    ksize = jj['ksize']
    radius = jj['radius']

    dirname = '{}_k{}_r{}_search_oh0'.format(catlas_base, ksize, radius)

    filenames = jj['search']
    z = []
    for x in filenames:
        x = os.path.basename(x)
        z.append(dirname + '/{}.{}'.format(x, suffix))

    return z


def catlas_search_sigs(conf_file, cdbg_only=False, suffix=''):
    "Produce the list of contigs.sig files output by 'conf/run <config> search"
    with open(conf_file, 'rt') as fp:
        jj = yaml.safe_load(fp)

    catlas_base = jj['catlas_base']
    ksize = jj['ksize']
    radius = jj['radius']

    cdbg_str = ""
    if cdbg_only:
        cdbg_str = '_cdbg'
    dirname = '{}_k{}_r{}{}_search_oh0{}'.format(catlas_base, ksize, radius,
                                                 cdbg_str, suffix)

    filenames = jj['search']
    z = []
    for x in filenames:
        x = os.path.basename(x)
        z.append(dirname + '/{}.contigs.sig'.format(x))

    return z

def plass_assemblies(conf_file):
    "Produce PLASS assemblies!"
    with open(conf_file, 'rt') as fp:
        jj = yaml.safe_load(fp)

    catlas_base = jj['catlas_base']
    ksize = jj['ksize']
    radius = jj['radius']

    dirname = '{}_k{}_r{}_search_oh0'.format(catlas_base, ksize, radius)

    filenames = jj['search']
    z = []
    for x in filenames:
        x = os.path.basename(x)
        output = dirname + '/{}.cdbg_ids.reads.gz.plass.cdhit.fa.clean.cut.dup.fa'.format(x)
        z.append(output)

    return z


def megahit_assemblies(conf_file):
    "Produce Megahit assemblies!"
    with open(conf_file, 'rt') as fp:
        jj = yaml.safe_load(fp)

    catlas_base = jj['catlas_base']
    ksize = jj['ksize']
    radius = jj['radius']

    dirname = '{}_k{}_r{}_search_oh0'.format(catlas_base, ksize, radius)

    filenames = jj['search']
    z = []
    for x in filenames:
        x = os.path.basename(x)
        output = dirname + '/{}.cdbg_ids.reads.gz.megahit.fa'.format(x)
        z.append(output)

    return z


def hardtrim_reads(conf_file):
    "Produce hardtrimmed reads!"
    with open(conf_file, 'rt') as fp:
        jj = yaml.safe_load(fp)

    catlas_base = jj['catlas_base']
    ksize = jj['ksize']
    radius = jj['radius']

    dirname = '{}_k{}_r{}_search_oh0'.format(catlas_base, ksize, radius)

    filenames = jj['search']
    z = []
    for x in filenames:
        x = os.path.basename(x)
        output = dirname + '/{}.cdbg_ids.reads.hardtrim.gz'.format(x)
        z.append(output)

    return z


def plass_hardtrim_reads(conf_file):
    "Produce plass assemblies of hardtrimmed reads!"
    with open(conf_file, 'rt') as fp:
        jj = yaml.safe_load(fp)

    catlas_base = jj['catlas_base']
    ksize = jj['ksize']
    radius = jj['radius']

    dirname = '{}_k{}_r{}_search_oh0'.format(catlas_base, ksize, radius)

    filenames = jj['search']
    z = []
    for x in filenames:
        x = os.path.basename(x)
        output = dirname + '/{}.cdbg_ids.reads.hardtrim.gz.plass.cdhit.fa'.format(x)
        z.append(output)

    return z

###

rule all:
    input:
#        catlas_search('conf/podar-ref.json'), CTB
#        catlas_search('conf/podar-ref.json', cdbg_only=True), CTB
        catlas_search('conf/podarV.json'),
        signatures(recover_fuso, recover_ruminis),
        signatures(strain_gingivalis, strain_denticola, strain_bacteroides),
        signatures(podar_ref_genomes, hu_bin_genomes),
        catlas_search('conf/podarV-ruminis.json', suffix='_ruminis'),
        catlas_search('conf/podarV-fuso.json', suffix='_fuso'),
        catlas_search('conf/podarV-denticola.json', suffix='_denticola'),
        catlas_search('conf/podarV-bacteroides.json', suffix='_bacteroides'),
        catlas_search('conf/podarV-gingivalis.json', suffix='_gingivalis'),
        "bacteroides.csv", "denticola.csv", "gingivalis.csv",
	"bacteroides.x.contigs.cont.csv",
	"denticola.x.contigs.cont.csv",
	"gingivalis.x.contigs.cont.csv",
        catlas_search('conf/hu-s1-pe.yaml'),
        catlas_extract_reads('conf/hu-s1-pe.yaml'),
        'fuso.reads.fa.megahit.fa', 'ruminis.reads.fa.megahit.fa',
        plass_assemblies('conf/hu-s1-pe.yaml'),
        "checkm-plass.txt",
        megahit_assemblies('conf/hu-s1-pe.yaml'),
        "checkm-megahit.txt",
        "checkm-hu.txt",
        signatures(megahit_assemblies('conf/hu-s1-pe.yaml')),
        signatures(catlas_extract_reads('conf/hu-s1-pe.yaml')),
        plass_hardtrim_reads('conf/hu-s1-pe.yaml'),
        "checkm-hardtrim-plass.txt",
        "megahit-containment.csv"

rule catlas_searches:
    input:
        catlas_search('conf/podar-ref.json'),
        catlas_search('conf/podar-ref.json', cdbg_only=True),
        catlas_search('conf/podarV.json'),
        signatures(recover_fuso, recover_ruminis),
        signatures(strain_gingivalis, strain_denticola, strain_bacteroides),
        signatures(podar_ref_genomes, hu_bin_genomes),
        catlas_search('conf/podarV-ruminis.json', suffix='_ruminis'),
        catlas_search('conf/podarV-fuso.json', suffix='_fuso'),
        catlas_search('conf/podarV-denticola.json', suffix='_denticola'),
        catlas_search('conf/podarV-bacteroides.json', suffix='_bacteroides'),
        catlas_search('conf/podarV-gingivalis.json', suffix='_gingivalis'),
        "bacteroides.csv", "denticola.csv", "gingivalis.csv",
	"bacteroides.x.contigs.cont.csv",
	"denticola.x.contigs.cont.csv",
	"gingivalis.x.contigs.cont.csv",
        catlas_search('conf/hu-s1-pe.yaml'),
        catlas_extract_reads('conf/hu-s1-pe.yaml'),
        signatures(megahit_assemblies('conf/hu-s1-pe.yaml')),
        signatures(catlas_extract_reads('conf/hu-s1-pe.yaml'))

rule download_podar_ref_genomes:
    output:
        podar_ref_genomes
    shell:
        """mkdir -p podar-ref && cd podar-ref && \
             (curl -L https://osf.io/8uxj9/?action=download | tar xzf -)"""

rule download_hu_bin_genomes:
    output:
        hu_bin_genomes
    shell:
        """mkdir -p hu-genomes && cd hu-genomes && \
             (curl -L https://osf.io/ehgbv/?action=download | tar xzf -)"""

rule download_podarV_strain_genomes:
    output:
        strain_denticola,
        strain_gingivalis,
        strain_bacteroides
    shell:
        "curl -L https://osf.io/h9emb/?action=download | tar xzf -"

rule download_podarV_recover_genomes:
    output:
        recover_ruminis,
        recover_fuso
    shell:
        "curl -L https://osf.io/w3xuf/?action=download | tar xzf -"


###

rule podar_ref_search:
    input:
        catlas_search_input('conf/podar-ref.json')
    output:
        catlas_search('conf/podar-ref.json')
    shell:
        "python -m spacegraphcats search conf/podar-ref.json --nolock"

rule podar_ref_search_cdbg_only:
    input:
        catlas_search_input('conf/podar-ref.json')
    output:
        catlas_search('conf/podar-ref.json', cdbg_only=True),
    shell:
        "python -m spacegraphcats search conf/podar-ref.json --cdbg-only --nolock"

rule podarV_build:
    input:
        "SRR606249.k31.abundtrim.fq.gz"
    output:
        catlas_build('conf/podarV.json'),
    shell:
        "python -m spacegraphcats build conf/podarV.json --nolock"

rule podarV_search:
    input:
        catlas_build('conf/podarV.json'),
        catlas_search_input('conf/podarV.json')
    output:
        catlas_search('conf/podarV.json'),
    shell:
        "python -m spacegraphcats search conf/podarV.json --nolock"

rule podarV_labeled_reads:
    input:
        "SRR606249.k31.abundtrim.fq.gz"
    output:
        "podarV_k31/reads.bgz.index",
        "podarV/reads.bgz"
    shell:
        "python -m spacegraphcats run conf/podarV.json {output} --nolock"

rule podarV_extract:
    input:
        catlas_search('conf/podarV.json')
    output:
        catlas_extract_reads('conf/podarV.json')
    threads: 16
    shell:
        "python -m spacegraphcats run conf/podarV.json extract_contigs extract_reads -j {threads} --nolock"


rule podarV_ruminis_search:
    input:
        recover_ruminis,
        catlas_build('conf/podarV.json'),
    output:
        catlas_search('conf/podarV-ruminis.json', suffix='_ruminis'),
    shell:
        "python -m spacegraphcats run conf/podarV-ruminis.json search --nolock"

rule combine_ruminis_nodes:
    input:
        expand("podarV_k31_r1_search_oh0_ruminis/{x}.cdbg_ids.txt.gz",
               x = [ os.path.basename(j) for j in recover_ruminis ])
    output:
        "ruminis-combined-node-list.txt.gz"
    shell:
        "gunzip -c {input} | gzip -9c > {output}"

rule extract_ruminis_reads:
    input:
        nodelist = "ruminis-combined-node-list.txt.gz",
        reads_bgz = "podarV/reads.bgz",
        reads_idx = "podarV_k31/reads.bgz.index"
    output:
        "ruminis.reads.fa"
    shell:
        "python -m spacegraphcats.search.extract_reads {input.reads_bgz} {input.reads_idx} {input.nodelist} -o {output}"

rule podarV_fuso_search:
    input:
        recover_fuso,
        catlas_build('conf/podarV.json'),
    output:
        catlas_search('conf/podarV-fuso.json', suffix='_fuso'),
    shell:
        "python -m spacegraphcats search conf/podarV-fuso.json --nolock"

rule combine_fuso_nodes:
    input:
        expand("podarV_k31_r1_search_oh0_fuso/{x}.cdbg_ids.txt.gz",
               x = [ os.path.basename(j) for j in recover_fuso ])
    output:
        "fuso-combined-node-list.txt.gz"
    shell:
        "gunzip -c {input} | gzip -9c > {output}"

rule extract_fuso_reads:
    input:
        nodelist = "fuso-combined-node-list.txt.gz",
        reads_bgz = "podarV/reads.bgz",
        reads_idx = "podarV_k31/reads.bgz.index"
    output:
        "fuso.reads.fa"
    shell:
        "python -m spacegraphcats.search.extract_reads {input.reads_bgz} {input.reads_idx} {input.nodelist} -o {output}"

rule podarV_bacteroides_search:
    input:
        strain_bacteroides
    output:
        catlas_search('conf/podarV-bacteroides.json', suffix='_bacteroides'),
    shell:
        "python -m spacegraphcats search conf/podarV-bacteroides.json --nolock"

rule podarV_gingivalis_search:
    input:
        strain_gingivalis
    output:
        catlas_search('conf/podarV-gingivalis.json', suffix='_gingivalis'),
    shell:
        "python -m spacegraphcats search conf/podarV-gingivalis.json --nolock"

rule podarV_denticola_search:
    input:
        strain_denticola
    output:
        catlas_search('conf/podarV-denticola.json', suffix='_denticola'),
    shell:
        "python -m spacegraphcats search conf/podarV-denticola.json --nolock"

rule denticola_compare:
    input:
        "podar-ref/56.fa.sig",
        signatures(strain_denticola)
    output:
        "denticola.csv"
    shell:
        "sourmash search {input} -n 0 --threshold=0.0 -o {output}"
        
rule gingivalis_compare:
    input:
        "podar-ref/37.fa.sig",
        signatures(strain_gingivalis)
    output:
        "gingivalis.csv"
    shell:
        "sourmash search {input} -n 0 --threshold=0.0 -o {output}"
        
rule bacteroides_compare:
    input:
        "podar-ref/4.fa.sig",
        signatures(strain_bacteroides)
    output:
        "bacteroides.csv"
    shell:
        "sourmash search {input} -n 0 --threshold=0.0 -o {output}"

rule bacteroides_search_cont:
    input:
        "podar-ref/4.fa.sig",
        catlas_search_sigs('conf/podarV-bacteroides.json',
                           suffix='_bacteroides')
    output:
        [ x + '.cont.csv' for x in 
                            catlas_search_sigs('conf/podarV-bacteroides.json',
                                               suffix='_bacteroides') ]
    shell:
        "for i in podarV_k31_r1_search_oh0_bacteroides/*.sig; do sourmash search podar-ref/4.fa.sig $i -o $i.cont.csv --threshold=0.0 -n 0 --containment; done"

rule bacteroides_summarize_cont:
    input:
        [ x + '.cont.csv' for x in
                             catlas_search_sigs('conf/podarV-bacteroides.json',
                                               suffix='_bacteroides') ]
    output:
        "bacteroides.x.contigs.cont.csv"
    shell:
        """head -1 podarV_k31_r1_search_oh0_bacteroides/GCA_900104585.1_PRJEB16348_genomic.fna.gz.contigs.sig.cont.csv > bacteroides.x.contigs.cont.csv &&
           for i in {input}; do tail -1 $i; done >> bacteroides.x.contigs.cont.csv
        """

rule gingivalis_search_cont:
    input:
        "podar-ref/37.fa.sig",
        catlas_search_sigs('conf/podarV-gingivalis.json',
                           suffix='_gingivalis')
    output:
        [ x + '.cont.csv' for x in 
                            catlas_search_sigs('conf/podarV-gingivalis.json',
                                               suffix='_gingivalis') ]
    shell:
        "for i in podarV_k31_r1_search_oh0_gingivalis/*.sig; do sourmash search podar-ref/37.fa.sig $i -o $i.cont.csv --threshold=0.0 -n 0 --containment; done"

rule gingivalis_summarize_cont:
    input:
        [ x + '.cont.csv' for x in
                             catlas_search_sigs('conf/podarV-gingivalis.json',
                                               suffix='_gingivalis') ]
    output:
        "gingivalis.x.contigs.cont.csv"
    shell:
        """head -1 podarV_k31_r1_search_oh0_gingivalis/GCA_900157325.1_3A1_genomic.fna.gz.contigs.sig.cont.csv > gingivalis.x.contigs.cont.csv &&
           for i in {input}; do tail -1 $i; done >> gingivalis.x.contigs.cont.csv
        """

rule denticola_search_cont:
    input:
        "podar-ref/56.fa.sig",
        catlas_search_sigs('conf/podarV-denticola.json',
                           suffix='_denticola')
    output:
        [ x + '.cont.csv' for x in 
                            catlas_search_sigs('conf/podarV-denticola.json',
                                               suffix='_denticola') ]
    shell:
        "for i in podarV_k31_r1_search_oh0_denticola/*.sig; do sourmash search podar-ref/56.fa.sig $i -o $i.cont.csv --threshold=0.0 -n 0 --containment; done"

rule denticola_summarize_cont:
    input:
        [ x + '.cont.csv' for x in
                             catlas_search_sigs('conf/podarV-denticola.json',
                                               suffix='_denticola') ]
    output:
        "denticola.x.contigs.cont.csv"
    shell:
        """head -1 podarV_k31_r1_search_oh0_denticola/GCA_900164975.1_16852_2_85_genomic.fna.gz.contigs.sig.cont.csv > denticola.x.contigs.cont.csv &&
           for i in {input}; do tail -1 $i; done >> denticola.x.contigs.cont.csv
        """

### hu-s1 rules

rule hu_s1_build:
    input:
        "SRR1976948.abundtrim.fq.gz"
    output:
        catlas_build('conf/hu-s1-pe.yaml'),
    shell:
        "python -m spacegraphcats build conf/hu-s1-pe.yaml --nolock"

rule hu_s1_search:
    input:
        catlas_build('conf/hu-s1-pe.yaml'),
        catlas_search_input('conf/hu-s1-pe.yaml')
    output:
        catlas_search('conf/hu-s1-pe.yaml'),
    shell:
        "python -m spacegraphcats search conf/hu-s1-pe.yaml --nolock"

rule hu_s1_labeled_reads:
    input:
        "SRR1976948.abundtrim.fq.gz"
    output:
        "hu-s1_k31/reads.bgz.index",
        "hu-s1/hu-s1.reads.bgz"
    shell:
        "python -m spacegraphcats run conf/hu-s1-pe.yaml {output} --nolock"

rule hu_s1_extract:
    input:
        catlas_search('conf/hu-s1-pe.yaml')
    output:
        catlas_extract_reads('conf/hu-s1-pe.yaml')
    threads: 16
    shell:
        "python -m spacegraphcats run conf/hu-s1-pe.yaml extract_contigs extract_reads -j {threads} --nolock"

### generic rules

rule compute_signature_for_genome:
    input:
        "{genomefile}"
    output:
        "{genomefile}.sig"
    shell:
        "sourmash compute -k 31 --scaled=1000 {input} -o {output}"

rule assemble_megahit:
    input:
        "{filename}"
    output:
        "{filename}.megahit.fa"
    conda:
        "envs/megahit.yaml"
    shell:
        "megahit -m 20e9 -o {output}.assemble -r {input} -f && cp {output}.assemble/final.contigs.fa {output}"

rule assemble_plass:
    input:
        "{filename}"
    output:
        "{filename}.plass.fa"
    conda:
        "envs/plass.yaml"
    shell:
        "plass assemble {input} {output} {input}.dir"

rule remove_plass_stop:
    input:
        "{filename}.plass.fa"
    output:
        "{filename}.plass.fa.nostop.fa"
    shell:
        "scripts/remove-stop-plass.py {input}"

rule plass_cd_hit:
    input:
        "{filename}.plass.fa.nostop.fa"
    output:
        "{filename}.plass.cdhit.fa"
    shell:
        "cd-hit -M 5000 -c 1 -i {input} -o {output}"

rule rename_plass_headers_clean:
    input:
        "{filename}.plass.cdhit.fa"
    output:
        "{filename}.plass.cdhit.fa.clean.cut.dup.fa"
    run:
        # rename sequences to be format 'hu-genome40_SRR1976948.1753381'
        with open(str(output), 'wt') as fp:
            for record in screed.open(str(input)):
                genome_name = str(input)
                genome_name = genome_name.split('/')[1]
                genome_name = genome_name.split('.')[0]
                seqname = record.name.split(' ')[0]
                newname = genome_name + '_' + seqname
                fp.write('>{}\n{}\n'.format(newname, record.sequence))

rule checkm_plass:
    input:
        plass_assemblies('conf/hu-s1-pe.yaml')
    output:
        directory("checkm.plass.out"),
        "checkm-plass.txt"
    conda:
        "envs/checkm.yaml"
    threads: 8
    shell: """
        rm -fr checkm.plass.bins
        mkdir checkm.plass.bins
        ln {input} checkm.plass.bins
        checkm lineage_wf -x fa checkm.plass.bins checkm.plass.out \
            -t {threads} --genes --pplacer_threads={threads} \
            -f checkm-plass.txt
    """


rule checkm_hardtrim_plass:
    input:
        plass_hardtrim_reads('conf/hu-s1-pe.yaml')
    output:
        directory("checkm.hardtrim-plass.out"),
        "checkm-hardtrim-plass.txt"
    conda:
        "envs/checkm.yaml"
    threads: 8
    shell:
        "rm -fr checkm.hardtrim-plass.bins && mkdir checkm.hardtrim-plass.bins && ln {input} checkm.hardtrim-plass.bins && checkm lineage_wf -x fa checkm.hardtrim-plass.bins checkm.hardtrim-plass.out -t {threads} --genes --pplacer_threads={threads} -f checkm-hardtrim-plass.txt"


rule checkm_megahit:
    input:
        megahit_assemblies('conf/hu-s1-pe.yaml')
    output:
        directory("checkm.megahit.out"),
        "checkm-megahit.txt"
    conda:
        "envs/checkm.yaml"
    threads: 8
    shell:
        "rm -fr checkm.megahit.bins && mkdir checkm.megahit.bins && ln {input} checkm.megahit.bins && checkm lineage_wf -x fa checkm.megahit.bins checkm.megahit.out -t {threads} --pplacer_threads={threads} -f checkm-megahit.txt"

rule checkm_hu:
    input:
        hu_bin_genomes
    output:
        directory("checkm.hu.out"),
        "checkm-hu.txt"
    threads: 8
    conda:
        "envs/checkm.yaml"
    shell:
        "rm -fr checkm.hu.bins && mkdir checkm.hu.bins && ln {input} checkm.hu.bins && checkm lineage_wf -x fa checkm.hu.bins checkm.hu.out -t {threads} --pplacer_threads={threads} -f checkm-hu.txt"

rule do_hardtrim_reads:
    input:
        "{filename}.gz"
    output:
        "{filename}.hardtrim.gz"
    shell:
        "trim-low-abund.py -C 5 -M 20e9 -k 31 {input} --gzip -o {output}"

rule megahit_read_containment:
    input:
        genome = "{filename}.sig",
        assembly = "{filename}.megahit.fa.sig"
    output:
        "{filename}.megahit.cont.csv"
    shell:
        "sourmash search --threshold=0.0 -k 31 --scaled=1000 {input.genome} {input.assembly} --containment -o {output}"

rule megahit_read_containment_summary:
    input:
        add_suffix_to_search_output('conf/hu-s1-pe.yaml',
                                    'cdbg_ids.reads.gz.megahit.cont.csv')
    output:
        "megahit-containment.csv"
    shell:
        "head -1 {input} > {output} && grep -hv 'similarity,' {input} >> {output}"

rule checkm_single_file:
    input:
        "{filename}.fa"
    output:
        bins = directory("checkm.{filename}.bins"),
        out = directory("checkm.{filename}.out"),
        summary = "checkm.{filename}.txt"
    conda:
        "envs/checkm.yaml"
    threads: 8
    shell:
        "rm -fr {output.bins} && mkdir {output.bins} && ln {input} {output.bins} && checkm lineage_wf -x fa {output.bins} {output.out} -t {threads} --pplacer_threads={threads} -f {output.summary}"
