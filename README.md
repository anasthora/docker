# Docker

Краткое описание: сборка docker-контейнера и его использование для запуска скрипта resolve_ref_alt.py 

## Содержание
- [Сборка образа](#сборка)
- [Использование](#использование)

## Сборка образа
Создание Dockerfile, в котором прописаны 8 слоев:
- 2 общих (слой общих зависимостей, Python 3 и pip; слой общих Python-библиотек для работы скриптов), 
- 6 специализированных программ и библиотек последних версий:
- - libdeflate — версия 1.26 (дата релиза: 2026-08-22) https://github.com/ebiggers/libdeflate/releases/download/v1.26/libdeflate-1.26.tar.gz 
- - HTSlib — версия 1.25 (дата релиза: 2026-10-27) https://github.com/samtools/htslib/releases/download/1.25/htslib-1.25.tar.bz2 
- - SAMtools — версия 1.25 (дата релиза: 2026-10-27) https://github.com/samtools/samtools/releases/download/1.25/samtools-1.25.tar.bz2
- - BCFtools — версия 1.25 (дата релиза: 2026-10-27) https://github.com/samtools/bcftools/releases/download/1.25/bcftools-1.25.tar.bz2
- - VCFtools — версия 0.1.17 (дата релиза: 2025-05-14) https://github.com/vcftools/vcftools/releases/download/v0.1.17/vcftools-0.1.17.tar.gz
- - pysam — версия 0.24.1 (дата релиза: 2026-09-07) https://github.com/pysam-developers/pysam/archive/refs/tags/v0.24.1.tar.gz 

Из папки, где лежит Dockerfile, запускаем команду сборки образа в терминале:
```bash
docker build -t test2:1.0 .
```
-t test2:1.0 — задаёт имя образа (test2) и его версию (1.0) <br>
. (точка в конце) — Dockerfile находится в текущей директории

проверка наличия нового образа:
```bash
docker images
```

## Использование
проверка версий установленных специализированных программ и библиотек (если успешно - отобразятся версии и "ОК"):
```bash
docker run --rm test2:1.0 bash -c '  samtools --version | head -n 2 &&   bcftools --version | head -n 2 &&   vcftools --version &&   python -c "import pysam; print(\"pysam version:\", pysam.__version__)" &&   echo «OK» '
```

запуск скрипта в контейнере из папки с данными для обработки и скриптом
(вместо переменной"$(pwd)" можно указать путь к папке с данными и скриптом)
```bash
docker run --rm -v "$(pwd)":/data test2:1.0 python3 resolve_ref_alt.py \
-i FP_SNPs_10k_GB38_twoAllelsFormat.tsv \
-f GRCh38.d1.vd1.fa \
-o FP_SNPs_10k_GB38_final.tsv  \
--err FP_SNPs_10k_GB38_errors.tsv \
--log FP_SNPs_10k_GB38.log
```



