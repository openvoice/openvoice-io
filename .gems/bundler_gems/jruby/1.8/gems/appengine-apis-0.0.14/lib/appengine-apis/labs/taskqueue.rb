#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2009 Google Inc.
# Original Author:: Ryan Brown (mailto:ribrdb@google.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# Task Queue API.
# 
# Enables an application to queue background work for itself. Work is done
# through webhooks that process tasks pushed from a queue. Tasks will execute in
# best-effort order of ETA. Webhooks that fail will cause tasks to be retried at
# a later time. Multiple queues may exist with independent throttling controls.
# 
# Webhook URLs may be specified directly for Tasks, or the default URL scheme
# may be used, which will translate Task names into URLs relative to a Queue's
# base path. A default queue is also provided for simple usage.

require 'appengine-apis/datastore_types'

module AppEngine
  module Labs
    module TaskQueue
      import com.google.appengine.api.labs.taskqueue.QueueFactory
      import com.google.appengine.api.labs.taskqueue.TaskOptions

      import com.google.appengine.api.labs.taskqueue.TaskAlreadyExistsException
      import com.google.appengine.api.labs.taskqueue.TransientFailureException
      import com.google.appengine.api.labs.taskqueue.InternalFailureException
      import com.google.appengine.api.labs.taskqueue.TaskAlreadyExistsException
      import com.google.appengine.api.labs.taskqueue.UnsupportedTranslationException

      class TaskAlreadyExistsError < StandardError; end
      class TransientFailureError < StandardError; end
      class InternalError < StandardError; end

      Blob = AppEngine::Datastore::Blob
      
      # Represents a single Task on a queue.
      class Task
        
        # Initializer.
        # 
        # All parameters are optional.
        # 
        # Options:
        # [:payload] The payload data for this Task that will be delivered to
        #      the webhook as the HTTP request body. This is only allowed for
        #      POST and PUT methods. Assumed to be UTF-8 unless it is a Blob.
        # [:bytes] Binary payload data for this Task.
        # [:countdown]: Time in seconds into the future that this Task should
        #      execute. Defaults to zero.
        # [:eta] Absolute time when the Task should execute. Must be a Time
        #      object. May not be specified if 'countdown' is also supplied.
        # [:headers] Hash of headers to pass to the webhook. Values in the
        #      hash may be enumerable to indicate repeated header fields.
        # [:method]: HTTP method to use when accessing the webhook. Defaults
        #      to 'POST'.
        # [:name] Name to give the Task; if not specified, a name will be
        #      auto-generated when added to a queue and assigned to this object.
        # [:params]: Hash of parameters to use for this Task.
        #      For POST requests these params will be encoded as
        #      'application/x-www-form-urlencoded' and set to the payload.
        #      For all other methods, the parameters will be converted to a
        #      query string. May not be specified if the URL already
        #      contains a query string.
        # [:url] Relative URL where the webhook that should handle this task is
        #      located for this application. May have a query string unless
        #      this is a POST method.
        # 
        # Raises:
        #   InvalidTaskError if any of the parameters are invalid;
        #   InvalidTaskNameError if the task name is invalid; InvalidUrlError if
        #   the task URL is invalid or too long; TaskTooLargeError if the task with
        #   its payload is too large.
        def initialize(payload=nil, options={})
          if payload.kind_of? Hash
            options, payload = payload, nil
          elsif payload.kind_of? TaskOptions
            @task_options = payload
            return
          end
          options = options.dup
          if payload.kind_of? Blob
            options[:bytes] = payload
          elsif payload
            options[:payload] = payload
          end
          @task_options = convert_options(options)
        end
        
       # Returns whether this Task has been enqueued.
        # 
        # Note: This will not check if this Task already exists in the queue.
        def enqueued?
          !!@handle
        end
        
        # Adds this Task to a queue
        #
        # Args:
        # - queue: Name of the queue where this Task should be added. (optional)
        #
        def add(queue=nil)
          queue = Queue.new(queue) unless queue.kind_of? Queue
          @handle = queue.java_queue.add(_task)
          self
        end
        
        # Returns the Time when this Task will execute.
        def eta
          Time.at(@handle.eta_millis / 1000.0) if @handle
        end
        
        # Returns the name of this Task.
        #
        # Will be nil if using an auto-assigned Task name and this Task has
        # not yet been added to a Queue.
        def name
          @handle.name if @handle
        end

        # Returns the name of the Queue where this Task was enqueued.
        def queue
          @handle.queue_name if @handle
        end

        private
        def convert_options(options)
          TaskQueue.convert_exceptions do
            task = TaskOptions::Builder.with_defaults
            if bytes = options.delete(:bytes)
              task.payload(bytes.to_java_bytes, 'application/octet-stream')
            end
            if payload = options.delete(:payload)
              task.payload(payload)
            end
            if countdown = options.delete(:countdown)
              millis = (countdown * 1000).round
              task.countdown_millis(millis)
            end
            if @eta = options.delete(:eta)
              millis = @eta.tv_sec * 1000 + @eta.tv_usec / 1000.0
              task.eta_millis(millis)
            end
            if headers = options.delete(:headers)
              headers.each do |key, value|
                if value.kind_of? Array
                  value = value.join(",")
                end
                task.header(key, value)
              end
            end
            if method = options.delete(:method)
              method = TaskOptions::Method.value_of(method.to_s.upcase)
              task.method(method)
            end
            if name = options.delete(:name)
              task.task_name(name)
            end
            if params = options.delete(:params)
              params.each do |name, param|
                if param.kind_of? Blob
                  param = param.to_java_bytes
                end
                task.param(name, param)
              end
            end
            if url = options.delete(:url)
              task.url(url)
            end
            task
          end
        end
        
        def _task
          @task_options
        end
        
      end
      
      # Represents a Queue.
      class Queue
        @queues = {}
        
        # Returns the named Queue, or the default queue if name is nil.
        #
        # The returned Queue object may not necessarily refer
        # to an existing queue.  Queues must be configured before
        # they may be used.  Attempting to use a non-existing queue name
        # may result in errors at the point of use of the Queue object,
        # not when creating it.
        def initialize(name=nil)
          TaskQueue.convert_exceptions do
            if name.nil?
              @queue = QueueFactory.default_queue
            else
              @queue = QueueFactory.get_queue(name)
            end
          end
        end
        
        def self.new(name=nil)
          @queues[name] ||= super
        end
        
        # Submits a task to this queue.
        def add(task=nil)
          if task.nil?
            Task.new.add(self)
          elsif task.java_kind_of? TaskOptions
            Task.new(task).add(self)
          else
            task.add(self)
          end
        end
        
        # Returns the name of this queue.
        def name
          @queue.queue_name
        end
        
        def java_queue
          @queue
        end
      end
      
      # Convenience method will create a Task and add it to the default queue.
      # 
      # Args:
      # - args: Passed to the Task constructor.
      # 
      # Returns:
      # - The Task that was added to the queue.
      def self.add(*args)
        Task.new(*args).add
      end
      
      def self.convert_exceptions
        begin
          yield
        rescue java.lang.IllegalArgumentException => ex
          raise ArgumentError, ex.message
        rescue UnsupportedTranslationException => ex
          raise ArgumentError, ex.message
        rescue TaskAlreadyExistsException => ex
          raise TaskAlreadExistsError, ex.message
        rescue InternalFailureException => ex
          raise InternalError, ex.message
        rescue TransientFailureException => ex
          raise TransientFailureError, ex.message
        end
      end
    end
  end
end
