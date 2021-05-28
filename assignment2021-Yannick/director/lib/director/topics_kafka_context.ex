defmodule Director.TopicsKafkaContext do

  alias KafkaEx.Protocol.CreateTopics.TopicRequest

  @topic_todo_tasks "todo-tasks"
  @create_topic_todo_tasks_request %TopicRequest{topic: @topic_todo_tasks, num_partitions: 2, replication_factor: 1}

  @topic_finished_tasks "finished-tasks"
  @create_topic_finished_tasks_request %TopicRequest{topic: @topic_finished_tasks, num_partitions: 2, replication_factor: 1}

  @topic_todo_chunks "todo-chunks"
  @create_topic_todo_chunks_request %TopicRequest{topic: @topic_todo_chunks, num_partitions: 2, replication_factor: 1}

  @topic_finished_chunks "finished-chunks"
  @create_topic_finished_chunks_request %TopicRequest{topic: @topic_finished_chunks, num_partitions: 2, replication_factor: 1}

  def create_topics(), do: KafkaEx.create_topics([@create_topic_todo_tasks_request, @create_topic_finished_tasks_request, @create_topic_todo_chunks_request, @create_topic_finished_chunks_request])

  def delete_topics(), do: KafkaEx.delete_topics([@topic_todo_tasks, @topic_finished_tasks, @topic_todo_chunks, @topic_finished_chunks])
end
