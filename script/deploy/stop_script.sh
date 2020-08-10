#!/bin/bash

ps -ef | grep mongodb_exporter | awk '{print $2}' | xargs kill -9
