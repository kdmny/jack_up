getFilesFromEvent = (event) ->
  if event.originalEvent.dataTransfer?
    event.originalEvent.dataTransfer.files
  else if event.originalEvent.currentTarget? && event.originalEvent.currentTarget.files?
    event.originalEvent.currentTarget.files
  else if event.originalEvent.target? && event.originalEvent.target.files?
    event.originalEvent.target.files
  else
    []

filesWithData = (event) ->
  _.map getFilesFromEvent(event), (file) ->
    file.__guid__ = Math.random().toString(36)
    file

class @JackUp.Processor
  constructor: (options) ->
    @uploadPath = options.path

  processFilesForEvent: (event) =>
    params = {}
    $zone = $(event.target).closest(".file-drop")
    _.map $zone.find("input"), (el) =>
      params[$(el).attr("name")] = $(el).val()
    _.each filesWithData(event), (file) =>
      reader = new FileReader()
      reader.onload = (event) =>
        @trigger 'upload:dataRenderReady', result: event.target.result, file: file

        if /^data:image/.test event.target.result
          image = $("<img>").attr("src", event.target.result)
          @trigger 'upload:imageRenderReady', image: image, file: file, zone: $zone

      reader.readAsDataURL(file)

      fileUploader = new JackUp.FileUploader(path: @uploadPath)
      @bubble 'upload:start', 'upload:success', 'upload:failure', 'upload:sentToServer', 'upload:percentComplete',
        from: fileUploader

      fileUploader.upload file: file, params: params, zone: $zone

_.extend JackUp.Processor.prototype, JackUp.Events
