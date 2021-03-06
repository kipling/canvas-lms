#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

module AssignmentsHelper
  def multiple_due_dates(varied_due_date)
    # can use this method as the single source of rendering multiple due dates
    # for now, just text, but eventually, a bubble/dialog/link/etc, rendering
    # the information contained in the varied_due_date parameter
    I18n.t '#assignments.multiple_due_dates', 'Multiple Due Dates'
  end

  def due_at(varied_due_date, format='datetime')
    if varied_due_date.multiple?
      multiple_due_dates(varied_due_date)
    else
      send("#{format}_string", varied_due_date.due_at, :short)
    end
  end
end
