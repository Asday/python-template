#!/usr/bin/env python

from glob import glob
import io
from os.path import basename, dirname, join, splitext
import re
from setuptools import find_packages, setup


setup(
    name='__PROJECT_NAME__',
    version='0.0.0',
    license='MIT',
    description='__DESCRIPTION__',
    long_description='',
    author='__AUTHOR__',
    author_email='__EMAIL__',
    url='',
    packages=find_packages('src'),
    package_dir={'': 'src'},
    py_modules=[splitext(basename(path))[0] for path in glob('src/*.py')],
    include_package_data=True,
    zip_safe=False,
    classifiers=[
        # complete classifier list: http://pypi.python.org/pypi?%3Aaction=list_classifiers
        'Development Status :: 1 - Planning',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
    install_requires=[
    ],
)
