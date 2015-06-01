Template.newChipModal.onRendered () ->	
	$('#datetimepicker_start').datetimepicker
		date: new Date @.data.start
		stepping: 30
	$('#datetimepicker_end').datetimepicker
		date: new Date @.data.end
		stepping: 30
	$('#datetimepicker_start').on 'dp.change', (e) ->
		$('#datetimepicker_end').data('DateTimePicker').minDate e.date
	$('#datetimepicker_end').on 'dp.change', (e) ->
	    $('#datetimepicker_start').data('DateTimePicker').maxDate e.date

Template.newChipModal.helpers
	data: () ->
		return Template.instance().data